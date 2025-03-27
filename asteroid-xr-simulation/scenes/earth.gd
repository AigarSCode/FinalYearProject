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

# Get todays date
var date = Time.get_date_string_from_system()

# HTTPRequest Node for API calls
var httprequestNode:HTTPRequest


func _ready() -> void:
	# Create a HTTPRequest Node and connect
	httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
	create_api_request()
	
	make_api_request()


func _process(delta: float) -> void:
	pass


# Make HTTP Request
func make_api_request():
	var error = httprequestNode.request(neows_request)
	if error != OK:
		print("Request Failed with error: " + str(error))


# API Response handling function
func _http_request_completed(result, response_code, headers, body) -> void:
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
	
	# Start asteroid movement
	activate_asteroids()


# Start asteroid movement all at the same time
func activate_asteroids():
	for asteroid in asteroidInstances:
		asteroid.start_movement = true


# Set a Random Texture to the asteroid instance
func set_asteroid_texture(asteroidInstance) -> void:
	# Pick a random number and set the texture of asteroid
	var randomNum = randi_range(0, 3)
	var mesh = asteroidInstance.get_node("AsteroidMesh")
	
	var asteroidMaterial = StandardMaterial3D.new()
	asteroidMaterial.albedo_texture = asteroidTextures[randomNum]
	
	mesh.set_surface_override_material(0, asteroidMaterial)
