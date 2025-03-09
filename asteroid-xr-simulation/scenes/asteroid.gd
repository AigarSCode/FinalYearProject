extends Node3D

var asteroidID:int
var asteroidName:String
var asteroidNEoWsID:int

# Asteroid Positional Information
var arrayX:Array = []
var arrayY:Array = []
var arrayZ:Array = []

# Scaling value for the distances, 2500 times smaller for the user experience
var scaleVal:int = 126000

# Positions for start and target
var start_pos:Vector3
var target_pos:Vector3

# Simulation time frame, 1 second is equal to 1 day
var simTimeFrame:float = 1.0
var elapsed_time:float = 0.0

# All array index
var i:int = 0

var init_complete = false

# Total time elapsed
var total_time:float = 0

#var api_horizons = "https://ssd.jpl.nasa.gov/api/horizons.api"
var api_horizons = "https://ssd.jpl.nasa.gov/api/horizons.api?format=json&COMMAND='{}'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTORS'&CENTER='500@399'&START_TIME='2025-02-19'&STOP_TIME='2025-03-05'&STEP_SIZE='1d'&QUANTITIES='1,9,20,23,24,29'"
var api_horizons_base = "https://ssd.jpl.nasa.gov/api/horizons.api"
var api_horizons_test_url = "https://ssd.jpl.nasa.gov/api/horizons.api?format=json&COMMAND='301'&OBJ_DATA='YES'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTORS'&CENTER='500@399'&START_TIME='2024-10-31'&STOP_TIME='2024-11-30'&STEP_SIZE='1d'&QUANTITIES='1,9,20,23,24,29'"
var api_response
var vector_table

var date = Time.get_date_string_from_system()
var start_time
var stop_time

var print:bool = true

func _ready() -> void:
	print("Asteroid Created with ID: " + str(asteroidID) + " and name: " + asteroidName)
	
	# Nasa Horizons API request for asteroid position
	var httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
	create_api_request()
	
	print("Asteroid ID: " + str(asteroidNEoWsID) + " has query: " + api_horizons)
	
	var error = httprequestNode.request(api_horizons)
	if error != OK:
		print("Request Failed with error: " + str(error))


func _physics_process(delta):
	DebugDraw2D.set_text("X", global_position.x)
	DebugDraw2D.set_text("Y", global_position.y)
	DebugDraw2D.set_text("Z", global_position.z)
	DebugDraw2D.set_text("Elapsed Time", elapsed_time)
	DebugDraw2D.set_text("Total elapsed time", total_time)
	
	if init_complete:
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
	if (asteroidNEoWsID >= 1 and asteroidNEoWsID <= 773916):
		asteroidDESID = str(asteroidNEoWsID)
	else:
		asteroidDESID = "DES=" + str(asteroidNEoWsID)
	
	set_date_range()
	
	# Make final API string
	api_horizons = "https://ssd.jpl.nasa.gov/api/horizons.api?format=json&COMMAND='" + asteroidDESID + "'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTORS'&CENTER='500@399'&STEP_SIZE='1d'&QUANTITIES='1'&VEC_TABLE='1'" + start_time + stop_time


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
	
	print("Start time is: ", start_time)
	print("Stop time is: ", stop_time)


func _http_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print("JSON for ID: " + str(asteroidNEoWsID) + " is: " + str(json.data))
	# Extract the Result of the Query (Contains the Vector Table)
	#var data = json.get_data()
	#print("Data for ID: " + str(asteroidNEoWsID) + " is: " + json.left(100))
	api_response = json.get_data().result
	
	extract_vector_table_elements()


# Taking the Result of the Query and extracting the Vector Table only
func extract_vector_table_elements() -> void:
	# Remove the text before the vector table
	vector_table = api_response.split("$$SOE")
	# Remove the text after the vector table
	vector_table = vector_table[1].split("$$EOE")
	# Keep only the vector table
	vector_table = vector_table[0]
	
	print("Vector Table is:", vector_table)
	
	extract_xyz_coordinates()


# Extract X, Y and Z values from the vector table
func extract_xyz_coordinates() -> void:
	var row = vector_table.split("\n")
	var coordinates
	
	for i in range(2, row.size(), 2):
		coordinates = row[i].split(" ")
		
		var index
		
		# The following handles positive and negative XYZ values since positive is X = 1.234 and negative is X =-1.234
		# Meaning split will split negative into ['X', '=-1.234'] causing an error
		if (coordinates[2].contains("E+")):
			index = 2
		else:
			index = 3
		
		if (coordinates[index].contains("=")):
			arrayX.append(float(coordinates[index].split("=")[1]))
		else:
			arrayX.append(float(coordinates[index]))
		
		index += 2
		
		if (coordinates[index].contains("=")):
			arrayY.append(float(coordinates[index].split("=")[1]))
		else:
			arrayY.append(float(coordinates[index]))
		
		index += 2
		
		if (coordinates[index].contains("=")):
			arrayZ.append(float(coordinates[index].split("=")[1]))
		else:
			arrayZ.append(float(coordinates[index]))
	
	init_elements()
