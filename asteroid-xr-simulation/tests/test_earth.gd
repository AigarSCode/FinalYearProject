extends GutTest

var asteroidScene = preload("res://scenes/asteroidScene.tscn")
var loadingBoxScene = preload("res://scenes/loading_box.tscn")
var earthScript = preload("res://scenes/earth.gd")
var earth
var date

func before_each():
	earth = earthScript.new()
	earth.date = "2025-01-01"
	
	for i in 10:
		earth.asteroidInstances.append(asteroidScene.instantiate())

# Test correct NeoWs request URL
func test_create_api_request():
	earth.create_api_request()
	var expected = "https://api.nasa.gov/neo/rest/v1/feed?api_key=DEMO_KEY&start_date=2025-01-01&end_date=2025-01-01"
	
	assert_eq(earth.neows_request, expected)


# Test if clear_asteroids actually removes them
func test_clear_asteroids():
	var numAsteroids = earth.asteroidInstances.size()
	assert_eq(numAsteroids, 10)
	
	earth.clear_asteroids()
	numAsteroids = earth.asteroidInstances.size()
	assert_eq(numAsteroids, 0)


# Test resetAsteroidVariables with different values
func test_resetAsteroidVariables():
	var loadingBox = loadingBoxScene.instantiate()
	loadingBox.visible = false
	
	var mesh = loadingBox.get_node("MeshInstance3D")
	var loadingBoxMesh = mesh.mesh
	
	var date_range_strings = ["2025-01-01", "2025-01-01", "2025-01-01"]
	
	earth.start_movement = true
	earth.elapsed_time = 0.76
	earth.loadingBox = loadingBox
	earth.loadingBoxMesh = loadingBoxMesh
	earth.date_range_strings = date_range_strings
	
	earth.resetAsteroidVariables()
	
	assert_eq(earth.start_movement, false)
	assert_eq(earth.elapsed_time, 0.0)
	assert_eq(earth.date_range_strings.size(), 0)
	assert_eq(earth.loadingBox.visible, true)


# Test set_date_range and verify dates are set
func test_set_date_range():
	var setDate = "2025-01-14"
	
	earth.set_date_range(setDate)
	
	assert_eq(earth.start_date, "2025-01-07")
	assert_eq(earth.stop_date, "2025-01-21")
	assert_eq(earth.date_range_strings[1], "2025-01-08")
	assert_eq(earth.date_range_strings.size(), 15)


# Test changeSpeed if the value changes
func test_changeSpeed():
	earth.changeSpeed(5.0)
	
	assert_eq(earth.simSpeed, 5.0)
