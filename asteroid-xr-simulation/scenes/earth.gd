extends Node3D

var asteroidScene:Resource = preload("res://scenes/asteroidScene.tscn")
# Asteroid Images from Solar System Scope (https://www.solarsystemscope.com/textures/)
var asteroidTextures = [preload("res://materials/Asteroid Textures/4k_ceres_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_eris_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_haumea_fictional.jpg"),
						preload("res://materials/Asteroid Textures/4k_makemake_fictional.jpg")]

var neows_base_request = "https://api.nasa.gov/neo/rest/v1/feed?api_key=DEMO_KEY"
var neows_request = ""
var api_response
var asteroidList
# Get todays date
var date = Time.get_date_string_from_system()

func _ready() -> void:
	# Request a list of asteroids for a set day
	# Currently manual
	var httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
	create_api_request()
	
	var error = httprequestNode.request(neows_request)
	if error != OK:
		print("Request Failed with error: " + str(error))

func _process(delta: float) -> void:
	pass
	

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
	var start_date = "&start_date=" + str(date)
	var end_date = "&end_date=" + str(date)
	neows_request = neows_base_request + start_date + end_date
	print("****** NEOWs Request is: " + str(neows_request))

# Function instantiates x number of asteroids from the NEoWs API response 
func create_asteroids() -> void:
	for asteroid in asteroidList:
		# Instantiate Asteroid Scene
		var asteroidInstance = asteroidScene.instantiate()
		
		# Set Invisibile
		asteroidInstance.get_node("AsteroidMesh").visible = false
		
		# Set a random asteroid texture
		set_asteroid_texture(asteroidInstance)
		
		# Set 0,0,0 coordinates
		asteroidInstance.position = Vector3(0,0,0)
		
		# Assign ID and NEO reference ID 
		asteroidInstance.asteroidID = asteroid.id
		asteroidInstance.asteroidNEoWsID = asteroid.neo_reference_id
		asteroidInstance.asteroidName = asteroid.name
		
		add_child(asteroidInstance)
		
		await get_tree().create_timer(0.5).timeout


# Set a Random Texture to the asteroid instance
func set_asteroid_texture(asteroidInstance) -> void:
	var randomNum = randi_range(0, 3)
	var mesh = asteroidInstance.get_node("AsteroidMesh")
	
	var asteroidMaterial = StandardMaterial3D.new()
	asteroidMaterial.albedo_texture = asteroidTextures[randomNum]
	
	mesh.set_surface_override_material(0, asteroidMaterial)
