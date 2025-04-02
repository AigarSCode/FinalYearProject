extends StaticBody3D

@onready var user = get_node("/root/Node3D/XROrigin3D/XRCamera3D")
@onready var earth = get_node("/root/Node3D/Earth")
var button1xMesh
var button2xMesh
var button3xMesh
var button0_5xMesh
var button0_3xMesh

var buttonSelected = preload("res://materials/ButtonSelected.tres")
var buttonUnselected = preload("res://materials/ButtonUnselected.tres")

var activeSpeed:String = "Speed1x"


func _ready() -> void:
	var parent = get_parent()
	
	button1xMesh = parent.get_node("Button1x/MeshInstance3D")
	button2xMesh = parent.get_node("Button2x/MeshInstance3D")
	button3xMesh = parent.get_node("Button3x/MeshInstance3D")
	button0_5xMesh = parent.get_node("Button0_5x/MeshInstance3D")
	button0_3xMesh = parent.get_node("Button0_3x/MeshInstance3D")
	


# Always face the user
func _process(_delta: float) -> void:
	if user != null:
		look_at(user.global_position, Vector3.UP)
		rotate_y(deg_to_rad(180))


# Change Speed and Button Material
func switchSpeed(speedButton) -> void:
	if speedButton == "Button1x":
		activeSpeed = "Speed1x"
		changeSimSpeed(1.0)
	elif speedButton == "Button2x":
		activeSpeed = "Speed2x"
		changeSimSpeed(2.0)
	elif speedButton == "Button3x":
		activeSpeed = "Speed3x"
		changeSimSpeed(3.0)
	elif speedButton == "Button0_5x":
		activeSpeed = "Speed0.5x"
		changeSimSpeed(0.5)
	elif speedButton == "Button0_3x":
		activeSpeed = "Speed0.3x"
		changeSimSpeed(0.333)
	
	changeSpeedButtonVisibility()


# Change speed in Earth
func changeSimSpeed(speed) -> void:
	earth.changeSpeed(speed)


# Make other Speed buttons invisible when one is in use
func changeSpeedButtonVisibility() -> void:
	# Change Button Material for selected and unselected states
	button1xMesh.material_override = buttonSelected if activeSpeed == "Speed1x" else buttonUnselected
	button2xMesh.material_override = buttonSelected if activeSpeed == "Speed2x" else buttonUnselected
	button3xMesh.material_override = buttonSelected if activeSpeed == "Speed3x" else buttonUnselected
	button0_5xMesh.material_override = buttonSelected if activeSpeed == "Speed0.5x" else buttonUnselected
	button0_3xMesh.material_override = buttonSelected if activeSpeed == "Speed0.3x" else buttonUnselected
