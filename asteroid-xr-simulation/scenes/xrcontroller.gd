extends XRController3D

@onready var ray = $RayCast3D
@onready var ray_mesh = $MeshInstance3D

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
			if triggerPressed or gripPressed:
				objectHit.createInfoBox()
				
		# Speed button Clicks
		elif objectHit.name in ["Button1x", "Button2x", "Button3x", "Button0_5x", "Button0_3x"]:
			if triggerPressed or gripPressed:
				objectHit.switchSpeed(objectHit.name)


# Change the ray mesh length to match ray length
func updateRayMesh(rayTip) -> void:
	var lengthToTarget = global_transform.origin.distance_to(rayTip)
	
	ray_mesh.scale.z = lengthToTarget / 5.0
	# Find the halfway point of the controller and ray tip and place ray mesh there
	ray_mesh.global_transform.origin = global_transform.origin + (rayTip - global_transform.origin) / 2
