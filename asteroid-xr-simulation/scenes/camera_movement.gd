extends Camera3D

@export var sensitivity:float = 10
@export var speed:float = 0.5

var controlling = true
var relative:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

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
func _process(delta: float) -> void:
	rotate(Vector3.DOWN, deg_to_rad(relative.x * deg_to_rad(sensitivity) * delta))
	rotate(transform.basis.x,deg_to_rad(- relative.y * deg_to_rad(sensitivity) * delta))
	relative = Vector2.ZERO
	
	var v = Vector3.ZERO
	
	var speedMultiplier = 1
	if Input.is_key_pressed(KEY_SHIFT):
		speedMultiplier = 3
	
	var turn = Input.get_axis("turn_left", "turn_right") - v.x	
	if abs(turn) > 0:   
		position = position + global_transform.basis.x * speed * turn * speedMultiplier * delta
	
	var moveFW_BW = Input.get_axis("move_forward", "move_backward")
	if abs(moveFW_BW) > 0:     
		global_translate(global_transform.basis.z * speed * moveFW_BW * speedMultiplier * delta)
	
	var moveUP_DWN = Input.get_axis("move_up", "move_down")
	if abs(moveUP_DWN) > 0:     
		global_translate(- global_transform.basis.y * speed * moveUP_DWN * speedMultiplier * delta)
