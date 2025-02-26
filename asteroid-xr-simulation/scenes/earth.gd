extends Node3D

var asteroidScene:Resource = preload("res://scenes/asteroidScene.tscn")

var neows_request = "https://api.nasa.gov/neo/rest/v1/feed?start_date=2025-02-20&end_date=2025-02-20&detailed=false&api_key=DEMO_KEY"
var api_response
var asteroidList
var date = "2025-02-20"

func _ready() -> void:
	# Request a list of asteroids for a set day
	# Currently manual
	var httprequestNode = HTTPRequest.new()
	add_child(httprequestNode)
	httprequestNode.request_completed.connect(self._http_request_completed)
	
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

# Function instantiates x number of asteroids from the NEoWs API response 
func create_asteroids() -> void:
	for asteroid in asteroidList:
		# Instantiate Asteroid Scene
		var asteroidInstance = asteroidScene.instantiate()
		
		# Set Invisibile
		asteroidInstance.get_node("AsteroidMesh").visible = false
		
		# Set 0,0,0 coordinates
		asteroidInstance.position = Vector3(0,0,0)
		
		# Assign ID and NEO reference ID 
		asteroidInstance.asteroidID = asteroid.id
		asteroidInstance.asteroidNEoWsID = asteroid.neo_reference_id
		asteroidInstance.asteroidName = asteroid.name
		
		#asteroidInstance.asteroidID = asteroidList[0].id
		#asteroidInstance.asteroidNEoWsID = asteroidList[0].neo_reference_id
		#asteroidInstance.asteroidName = asteroidList[0].name
		
		add_child(asteroidInstance)
		
		await get_tree().create_timer(0.5).timeout
