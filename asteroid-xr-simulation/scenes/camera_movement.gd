extends Camera3D

@export var sensitivity:float = 10
@export var speed:float = 0.5

var controlling = true
var relative:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
# Mouse is hidden when game initially launches
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

# Input handling, If mouse is moving and controlling is true then make the movement
# If ESC is hit, make the mouse appear, and stop mouse movement being captured
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and controlling:
		relative = event.relative
	if event.is_action_pressed("ui_cancel"):
		if controlling:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
		controlling = !controlling


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Rotate and movement
func _process(delta: float) -> void:
	# Rotate in the Horizontal
	rotate(Vector3.DOWN, deg_to_rad(relative.x * deg_to_rad(sensitivity) * delta))
	# Rotate in the Vertical
	rotate(transform.basis.x,deg_to_rad(- relative.y * deg_to_rad(sensitivity) * delta))
	# Reset relative
	relative = Vector2.ZERO
	
	var v = Vector3.ZERO
	
	# Set movement speed and increase if SHIFT is pressed
	var speedMultiplier = 1
	if Input.is_key_pressed(KEY_SHIFT):
		speedMultiplier = 3
	
	# Vertical/Horizontal/Forward/Backward movement
	var turn = Input.get_axis("turn_left", "turn_right") - v.x	
	if abs(turn) > 0:   
		position = position + global_transform.basis.x * speed * turn * speedMultiplier * delta
	
	var moveFW_BW = Input.get_axis("move_forward", "move_backward")
	if abs(moveFW_BW) > 0:     
		global_translate(global_transform.basis.z * speed * moveFW_BW * speedMultiplier * delta)
	
	var moveUP_DWN = Input.get_axis("move_up", "move_down")
	if abs(moveUP_DWN) > 0:     
		global_translate(- global_transform.basis.y * speed * moveUP_DWN * speedMultiplier * delta)
