extends Node3D

var asteroidScene:Resource = preload("res://scenes/asteroidScene.tscn")
var asteroidInstances:Array

# Asteroid Images from Solar System Scope (https://www.solarsystemscope.com/textures/)
var asteroidTextures = [preload("res://materials/Asteroid Textures/4k_ceres_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_eris_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_haumea_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_makemake_fictional.jpg")]

var neows_base_request = "https://api.nasa.gov/neo/rest/v1/feed?api_key=DEMO_KEY"
var neows_request = ""
var api_response
var asteroidList
var numberOfAsteroids:int = 0
var numberOfReadyAsteroids:int = 0

# Get todays date
var date = Time.get_date_string_from_system()
var start_date:String
var stop_date:String
var current_date
var current_date_counter
var date_range_strings:Array
var start_movement:bool = false
var date_searchable:bool = true
@onready var dateBoxScene = $"../DateBox"
# Days forward and backward in the simulation
var date_range = 7
var total_date_range = 15

var simTimeFrame:float = 1.0
var elapsed_time:float = 0.0
var simSpeed:float = 1.0

# HTTPRequest Node for API calls
var httprequestNode:HTTPRequest


func _ready() -> void:
	# Set date range
	current_date_counter = 0
	set_date_range(date)
	current_date = date_range_strings[current_date_counter]
	
	# Create a HTTPRequest Node and connect
	httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
	create_api_request()
	make_api_request()


# Asteroid Movement Moved to Earth to reduce complexity of individual asteroid calculation
func _process(delta: float) -> void:
	# Move all asteroids
	if start_movement:
		elapsed_time += delta * simSpeed
		if elapsed_time >= simTimeFrame:
			elapsed_time -= simTimeFrame
			# Change UI date
			update_current_date()
			# Calculate asteroid target position
			calculate_next_positions()
		var weight = elapsed_time / simTimeFrame
		move_asteroids(weight)


# Make HTTP Request
func make_api_request():
	var error = httprequestNode.request(neows_request)
	if error != OK:
		print("Request Failed with error: " + str(error))


# API Response handling function
func _http_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	api_response = json.get_data()
	
	# Parsing API response
	if (api_response.element_count <= 0):
		print("Number of asteroids is 0 or less")
	else:
		asteroidList = api_response["near_earth_objects"][date]
		for asteroid in asteroidList:
			print("Asteroid: " + asteroid.name + " with ID: " + asteroid.id)
	
	create_asteroids()


func create_api_request() -> void:
	# Construct API string
	var start_date = "&start_date=" + str(date)
	var end_date = "&end_date=" + str(date)
	neows_request = neows_base_request + start_date + end_date
	print("****** NEOWs Request is: " + str(neows_request))


# Function instantiates x number of asteroids from the NEoWs API response 
func create_asteroids() -> void:
	for asteroid in asteroidList:
		numberOfAsteroids += 1
		# Instantiate Asteroid Scene
		var asteroidInstance = asteroidScene.instantiate()
		asteroidInstance.name = "asteroid_" + str(numberOfAsteroids)
		
		# Connect asteroid ready signal for movement
		asteroidInstance.connect("initComplete", Callable(self, "_on_asteroid_init_completed"))
		
		# Set Invisibile
		asteroidInstance.get_node("AsteroidMesh").visible = false
		
		# Set a random asteroid texture
		set_asteroid_texture(asteroidInstance)
		
		# Set 0,0,0 coordinates
		asteroidInstance.position = Vector3(0,0,0)
		asteroidInstance.asteroidInfoMarker = $"../AsteroidInfoUIMarker"
		
		# Assign ID and NEO reference ID 
		asteroidInstance.asteroidID = asteroid.id
		asteroidInstance.asteroidNeoWsID = asteroid.neo_reference_id
		asteroidInstance.asteroidName = asteroid.name
		
		# Assign extra information
		asteroidInstance.estimated_diameterKm_min = asteroid["estimated_diameter"]["kilometers"]["estimated_diameter_min"]
		asteroidInstance.estimated_diameterKm_max = asteroid["estimated_diameter"]["kilometers"]["estimated_diameter_max"]
		asteroidInstance.estimated_diameterMi_min = asteroid["estimated_diameter"]["miles"]["estimated_diameter_min"]
		asteroidInstance.estimated_diameterMi_max = asteroid["estimated_diameter"]["miles"]["estimated_diameter_max"]
		asteroidInstance.is_potentially_hazardous = asteroid.is_potentially_hazardous_asteroid
		asteroidInstance.is_sentry_object = asteroid.is_sentry_object
		
		# Close approach information
		var close_approach_data = asteroid["close_approach_data"][0]
		asteroidInstance.orbitingBody = close_approach_data["orbiting_body"]
		asteroidInstance.dateFull = close_approach_data["close_approach_date_full"]
		asteroidInstance.relativeVelKm = close_approach_data["relative_velocity"]["kilometers_per_hour"]
		asteroidInstance.relativeVelMi = close_approach_data["relative_velocity"]["miles_per_hour"]
		asteroidInstance.missDistKm = close_approach_data["miss_distance"]["kilometers"]
		asteroidInstance.missDistMi = close_approach_data["miss_distance"]["miles"]
		asteroidInstance.missDistAU = close_approach_data["miss_distance"]["astronomical"]
		
		asteroidInstances.append(asteroidInstance)
		
		add_child(asteroidInstance)
		
		# Wait before sending another request
		# Fixes issue when sending all requests at once
		await get_tree().create_timer(0.5).timeout


# Function to move asteroids to next position
func move_asteroids(weight) -> void:
	for asteroid in asteroidInstances:
		asteroid.move_asteroid(weight)


# Calculate next position of all asteroids
func calculate_next_positions() -> void:
	for asteroid in asteroidInstances:
		asteroid.create_next_target_position()


# Counter to check if all asteroids are ready to move
func _on_asteroid_init_completed() -> void:
	numberOfReadyAsteroids += 1
	
	if numberOfReadyAsteroids == numberOfAsteroids:
		start_movement = true
		date_searchable = true
		
		# Hide loading box
		$"../LoadingBox".visible = false


# Set a Random Texture to the asteroid instance
func set_asteroid_texture(asteroidInstance) -> void:
	# Pick a random number and set the texture of asteroid
	var randomNum = randi_range(0, 3)
	var mesh = asteroidInstance.get_node("AsteroidMesh")
	
	var asteroidMaterial = StandardMaterial3D.new()
	asteroidMaterial.albedo_texture = asteroidTextures[randomNum]
	
	mesh.set_surface_override_material(0, asteroidMaterial)


# Clears the current asteroids from the world
func clear_asteroids() -> void:
	for asteroid in asteroidInstances:
		# Close UI before deleting
		if asteroid.displayingUI:
			asteroid.displayInfoBox()
		asteroid.free()
	asteroidInstances.clear()


# Reset a list of variables before creating new asteroids
func resetAsteroidVariables() -> void:
	# Movement Related
	start_movement = false
	elapsed_time = 0.0
	
	# Loading Box
	$"../LoadingBox".visible = true
	
	# Counters for Asteroid and Date
	numberOfAsteroids = 0
	numberOfReadyAsteroids = 0
	current_date_counter = 0


# Search for new asteroids using a User selected Date
func searchUserDate(userDate) -> void:
	# Limit searches until the first is complete
	if date_searchable:
		date_searchable = false
		# Clear asteroids and reset some of the variables
		clear_asteroids()
		resetAsteroidVariables()
		
		# Update Search Date
		date = userDate
		set_date_range(userDate)
		current_date = date_range_strings[current_date_counter]
		
		# Run API url creation and Send request
		create_api_request()
		make_api_request()
		
		# Create asteroids with returned data
		create_asteroids()


# Set the date range, "date_range" days back and forward
func set_date_range(setDate) -> void:
	var date_back = setDate
	var date_forw = date_back.duplicate(true)
	
	# Date needs to be converted to unix time before being able to add 7 days and take away 7 days
	var unix_time_back = Time.get_unix_time_from_datetime_dict(date_back) - (date_range * 86400)
	var unix_time_forw = Time.get_unix_time_from_datetime_dict(date_forw) + (date_range * 86400)
	
	# Get only the date part (YYYY-MM-DD) of the datetime_string (YYYY-MM-DD HH:MM:SS)
	start_date = Time.get_datetime_string_from_unix_time(unix_time_back, true).split(" ")[0]
	stop_date = Time.get_datetime_string_from_unix_time(unix_time_forw, true).split(" ")[0]
	
	# Get entire date range as strings for each day
	for i in range(total_date_range):
		var unix_date = unix_time_back + (i * 86400)
		
		# Get only the date part (YYYY-MM-DD) of the datetime_string (YYYY-MM-DD HH:MM:SS)
		date_range_strings.append(Time.get_datetime_string_from_unix_time(unix_date, true).split(" ")[0])


# Increments the current date string by 1 day and Changes the DateBox UI to reflect that
func update_current_date() -> void:
	current_date_counter += 1
	
	if current_date_counter >= total_date_range:
		current_date_counter = 0
	
	current_date = date_range_strings[current_date_counter]
	
	# Set the date on the DateBox UI
	dateBoxScene.get_node("LabelDate").text = current_date


# Change Sim Speed, set by SpeedBox UI
func changeSpeed(speed) -> void:
	simSpeed = speed
