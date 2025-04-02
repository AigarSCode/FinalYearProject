extends Node3D

@onready var user = $"../XROrigin3D/XRCamera3D"

# Always face the user
func _process(_delta: float) -> void:
	look_at(user.global_position, Vector3.UP)
	rotate_y(deg_to_rad(180))
