extends Node3D

# Asteroid Information
var asteroidID:int
var asteroidName:String
var asteroidNeoWsID:int
var orbitingBody:String
var dateFull:String
var relativeVelKm:float
var relativeVelMi:float
var missDistKm:float
var missDistMi:float
var missDistAU:float
var estimated_diameterKm_min:float
var estimated_diameterKm_max:float
var estimated_diameterMi_min:float
var estimated_diameterMi_max:float
var is_potentially_hazardous:bool
# Sentry object boolean (https://cneos.jpl.nasa.gov/sentry/)
var is_sentry_object:bool
var source:String
var producer:String
var earliestObs:String
var latestObs:String
var element_data_dictionary:Dictionary = {}


# Asteroid Positional Information
var arrayX:Array = []
var arrayY:Array = []
var arrayZ:Array = []

# Scaling value for the distances adjusted for user experience
var scaleVal:int

# Positions for start and target
var start_pos:Vector3
var target_pos:Vector3

# Simulation time frame, 1 second is equal to 1 day
var simTimeFrame:float = 1.0
var elapsed_time:float = 0.0

# All array index
var i:int = 0

var init_complete:bool = false
var start_movement:bool = false
var is_paused:bool = false

# Total time elapsed
var total_time:float = 0

var httprequestNode:HTTPRequest
var sbdb_base_request = "https://ssd-api.jpl.nasa.gov/sbdb.api?sstr="
var api_horizons
var api_response
var vector_table

var date = Time.get_date_string_from_system()
var start_time
var stop_time


func _ready() -> void:
	print("Asteroid Created with ID: " + str(asteroidID) + " and name: " + asteroidName)
	
	# Nasa Horizons API request for asteroid position
	httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
	create_api_request()
	
	print("Asteroid ID: " + str(asteroidNeoWsID) + " has query: " + api_horizons)
	
	make_api_request(api_horizons)


func _physics_process(delta):
	
	if init_complete and start_movement:
		# Move the object to the target position from the starting position over 1 second
		# Once moved to target, increase array index, set start position to current position, recalculate target and continue moving
		if elapsed_time < simTimeFrame:
			elapsed_time += delta
			total_time += delta
			var weight = elapsed_time / simTimeFrame
			global_position = start_pos.slerp(target_pos, weight)
		else:
			if i < arrayX.size() - 2:
				i += 1
				elapsed_time = 0.0
				start_pos = global_position
				target_pos = calculate_target_vector()
				
			else:
				i = 0
				elapsed_time = 0.0
				start_pos = global_position
				target_pos = calculate_target_vector()

# Calculate and return a Vector3 for a position
func calculate_target_vector():
	return Vector3((arrayX[i] / scaleVal), (arrayY[i] / scaleVal), (arrayZ[i] / scaleVal))


# Function for setting initial values
func init_elements() -> void:
	start_pos = calculate_target_vector()
	global_position = start_pos
	i += 1
	target_pos = calculate_target_vector()
	$AsteroidMesh.visible = true
	init_complete = true


# Construct the API request string
func create_api_request() -> void:
	start_time = "&START_TIME="
	stop_time = "&STOP_TIME="
	
	# Asteroids with a high ID over 773916 need to be searched with "DES=" before the ID
	var asteroidDESID
	if (asteroidNeoWsID >= 1 and asteroidNeoWsID <= 773916):
		asteroidDESID = str(asteroidNeoWsID)
	else:
		asteroidDESID = "DES=" + str(asteroidNeoWsID)
	
	set_date_range()
	
	# Make final API string
	api_horizons = "https://ssd.jpl.nasa.gov/api/horizons.api?format=json&COMMAND='" + asteroidDESID + "'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTORS'&CENTER='500@399'&STEP_SIZE='1d'&QUANTITIES='1'&VEC_TABLE='1'" + start_time + stop_time


func make_api_request(request_url):
	var error = httprequestNode.request(request_url)
	if error != OK:
		print("Request Failed with error: " + str(error))


# Setting the date range for the API call, for now this is 7 days back and 7 days forward
func set_date_range() -> void:
	var date_back = Time.get_datetime_dict_from_system()
	var date_forw = date_back.duplicate(true)
	
	# Date needs to be converted to unix time before being able to add 7 days and take away 7 days
	var unix_time_back = Time.get_unix_time_from_datetime_dict(date_back) - (7 * 86400)
	var unix_time_forw = Time.get_unix_time_from_datetime_dict(date_forw) + (7 * 86400)
	
	date_back = Time.get_datetime_dict_from_unix_time(unix_time_back)
	date_forw = Time.get_datetime_dict_from_unix_time(unix_time_forw)
	
	# Get only the date part (YYYY-MM-DD) of the datetime_string (YYYY-MM-DD HH:MM:SS)
	start_time = start_time + Time.get_datetime_string_from_datetime_dict(date_back, true).split(" ")[0]
	stop_time = stop_time + Time.get_datetime_string_from_datetime_dict(date_forw, true).split(" ")[0]


# Function that is called when an API request is completed, used to extract response body
func _http_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	#print("JSON for ID: " + str(asteroidNeoWsID) + " is: " + str(json.data))
	# Extract the Result of the Query (Contains the Vector Table)
	api_response = json.get_data().result
	
	extract_vector_table_elements()


# Taking the Result of the Query and extracting the Vector Table only
func extract_vector_table_elements() -> void:
	# Remove the text before the vector table (Start Of Ephemeris)
	vector_table = api_response.split("$$SOE")
	# Remove the text after the vector table (End Of Ephemeris)
	vector_table = vector_table[1].split("$$EOE")
	# Keep only the vector table
	vector_table = vector_table[0]
	
	#print("Vector Table is:", vector_table)
	
	extract_xyz_coordinates()


# Extract X, Y and Z values from the vector table
func extract_xyz_coordinates() -> void:
	var row = vector_table.split("\n")
	var coordinates
	
	# Set ScaleVal for different distances
	var individual_coordinates = row[2].split("Y")
	if individual_coordinates[0].contains("E+04"):
		scaleVal = 5000
	elif individual_coordinates[0].contains("E+05"):
		scaleVal = 50000
	elif individual_coordinates[0].contains("E+06"):
		scaleVal = 150000
	elif individual_coordinates[0].contains("E+07"):
		scaleVal = 1500000
	elif individual_coordinates[0].contains("E+08"):
		scaleVal = 15000000
	elif individual_coordinates[0].contains("E+09"):
		scaleVal = 150000000
	
	
	for i in range(2, row.size(), 2):
		var xPos
		var yPos
		var zPos
		coordinates = row[i].split(" ")
		
		# The following handles positive and negative XYZ values since positive is X = 1.234 and negative is X =-1.234
		# The previous implementation of split will split negative into ['X', '=-1.234'] causing an error
		# New Implementation finds the index of each element and take the next value or the one after
		
		# X
		xPos = coordinates.find("X")
		if (coordinates[xPos + 1] == "="):
			arrayX.append(float(coordinates[xPos + 2]))
		elif (coordinates[xPos + 1].contains("E+")):
			arrayX.append(float(coordinates[xPos + 1].split("=")[1]))
		
		# Y 
		yPos = coordinates.find("Y")
		if (coordinates[yPos + 1] == "="):
			arrayY.append(float(coordinates[yPos + 2]))
		elif (coordinates[yPos + 1].contains("E+")):
			arrayY.append(float(coordinates[yPos + 1].split("=")[1]))
		
		# Z
		zPos = coordinates.find("Z")
		if (coordinates[zPos + 1] == "="):
			arrayZ.append(float(coordinates[zPos + 2]))
		elif (coordinates[zPos + 1].contains("E+")):
			arrayZ.append(float(coordinates[zPos + 1].split("=")[1]))
	
	init_elements()


# Creates Orbital Data API request only when asteroid gets selected
func get_asteroid_orbital_data():
	var request_orbital_data_url = sbdb_base_request + str(asteroidNeoWsID)
	
	make_api_request(request_orbital_data_url)


# Extract all asteroid orbial information for display use
func extract_asteroid_orbital_data(orbital_data):
	var elements = orbital_data["orbit"]["elements"]
	var otherOrbit = orbital_data["orbit"]
	
	# For each element, construct a visual string e.g "perihelion distance = 1.03 au (q)"
	for element in elements:
		var element_string
		
		if element.units == null:
			element_string = element.title + " = " + str(element.value) + " (" + element.label + ")"
		else:
			element_string = element.title + " = " + str(element.value) + " " + element.units + " (" + element.label + ")"
		
		# Store string in dictionary for use
		element_data_dictionary[element.name] = element_string
	
	# Set other orbit data
	source = otherOrbit.source
	producer = otherOrbit.producer
	earliestObs = otherOrbit.first_obs
	latestObs = otherOrbit.last_obs
	
