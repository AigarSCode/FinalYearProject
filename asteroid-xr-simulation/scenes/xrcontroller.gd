extends XRController3D

@onready var ray = $RayCast3D
@onready var ray_mesh = $MeshInstance3D
@onready var datePickerUI = get_node("/root/Node3D/DatePicker")
@onready var earth = get_node("/root/Node3D/Earth")

func _ready() -> void:
	pass


# Update the visible part of the Ray Cast
func _process(_delta: float) -> void:
	var triggerPressed = is_button_pressed("trigger")
	var gripPressed = is_button_pressed("trigger")
	
	# If the ray hits something, the length of the visible mesh needs to be updated
	if ray.is_colliding():
		var collisionVector = ray.get_collision_point()
		updateRayMesh(collisionVector)
	else:
		var maxLenVector = ray.global_transform * ray.target_position
		updateRayMesh(maxLenVector)
	
	# Handle Controller Ray Asteroid and UI collisions
	# Check if colliding, then check if its a button, make function call if button is pressed
	if ray.is_colliding():
		var objectHit = ray.get_collider()
		
		# Clicks for Tabs in Info Box
		if objectHit.name in ["TabButton1", "TabButton2", "TabButton3"]:
			if triggerPressed or gripPressed:
				var infoBox = objectHit.get_parent()
				infoBox.switchTab(objectHit.name)
				
		# Asteroid Clicks
		elif objectHit.name.contains("asteroid"):
			print("Asteroid CLICK: " + objectHit.name)
			if triggerPressed or gripPressed:
				objectHit.createInfoBox()
				
		# Speed button Clicks
		elif objectHit.name in ["Button1x", "Button2x", "Button3x", "Button0_5x", "Button0_3x"]:
			if triggerPressed or gripPressed:
				objectHit.switchSpeed(objectHit.name)
		
		elif objectHit.get_parent().name == "DatePicker":
			if triggerPressed or gripPressed:
				datePickerOptions(objectHit.name)


# Handler for each Date Picker UI button 
func datePickerOptions(objectHitName) -> void:
	if objectHitName == "DateUp": datePickerUI.incrementDates("day")
	if objectHitName == "DateDown": datePickerUI.decrementDates("day")
	if objectHitName == "MonthUp": datePickerUI.incrementDates("month")
	if objectHitName == "MonthDown": datePickerUI.decrementDates("month")
	if objectHitName == "YearUp": datePickerUI.incrementDates("year")
	if objectHitName == "YearDown": datePickerUI.decrementDates("year")
	
	# Submit search to Earth
	if objectHitName == "Search":
		earth.searchUserDate(datePickerUI.dateString)


# Change the ray mesh length to match ray length
func updateRayMesh(rayTip) -> void:
	var lengthToTarget = global_transform.origin.distance_to(rayTip)
	
	ray_mesh.scale.z = lengthToTarget / 5.0
	# Find the halfway point of the controller and ray tip and place ray mesh there
	ray_mesh.global_transform.origin = global_transform.origin 	+ (rayTip - global_transform.origin) / 2
