extends Node3D

@onready var user = $"../XROrigin3D/XRCamera3D"

# Always face the user
func _process(_delta: float) -> void:
	if user != null:
	# Issue encountered, Users height was not taken into account. Now height is offset to face the user
		var user_camera_pos = user.global_position
		user_camera_pos.y = global_position.y
		look_at(user_camera_pos, Vector3.UP)
		rotate_y(deg_to_rad(180))
