extends StaticBody3D

@onready var user = $"../XROrigin3D/XRCamera3D"

var buttonSelected = preload("res://materials/ButtonSelected.tres")
var buttonUnselected = preload("res://materials/ButtonUnselected.tres")

var activeSpeed:String = "Speed1x"


func _ready() -> void:
	pass


# Always face the user
func _process(_delta: float) -> void:
	look_at(user.global_position, Vector3.UP)
	rotate_y(deg_to_rad(180))


# Change Speed and Button Material
func switchSpeed(speedButton) -> void:
	if speedButton == "Button1x":
		activeSpeed = "Speed1x"
		changeSimSpeed(1.0)
	elif speedButton == "Button2x":
		activeSpeed = "Speed2x"
		changeSimSpeed(0.5)
	elif speedButton == "Button3x":
		activeSpeed = "Speed3x"
		changeSimSpeed(0.333)
	elif speedButton == "Button0_5x":
		activeSpeed = "Speed0.5x"
		changeSimSpeed(2.0)
	elif speedButton == "Button0_3x":
		activeSpeed = "Speed0.3x"
		changeSimSpeed(3.0)
	
	changeSpeedButtonVisibility()


# Change speed in Earth
func changeSimSpeed(speed) -> void:
	$"../Earth".changeSpeed(speed)


# Make other Speed buttons invisible when one is in use
func changeSpeedButtonVisibility() -> void:
	# Change Button Material for selected and unselected states
	$Button1x.get_node("MeshInstance3D").material_override = buttonSelected if activeSpeed == "Speed1x" else buttonUnselected
	$Button2x.get_node("MeshInstance3D").material_override = buttonSelected if activeSpeed == "Speed2x" else buttonUnselected
	$Button3x.get_node("MeshInstance3D").material_override = buttonSelected if activeSpeed == "Speed3x" else buttonUnselected
	$Button0_5x.get_node("MeshInstance3D").material_override = buttonSelected if activeSpeed == "Speed0.5x" else buttonUnselected
	$Button0_3x.get_node("MeshInstance3D").material_override = buttonSelected if activeSpeed == "Speed0.3x" else buttonUnselected
