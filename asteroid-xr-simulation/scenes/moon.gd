extends Node3D

# API URL 
# https://ssd.jpl.nasa.gov/api/horizons.api?format=json&COMMAND='301'&OBJ_DATA='YES'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTORS'&CENTER='500@399'&START_TIME='2024-10-31'&STOP_TIME='2024-11-30'&STEP_SIZE='1d'&QUANTITIES='1,9,20,23,24,29'
# Arrays hold the X Y Z coordinates
var arrayX:Array = [-3.786734490281973, -3.395751117227855, -2.852780041256374, -2.180959610662535, -1.409547212977494, -5.731959655821673, 2.890235289204603, 
					1.134854083311371, 1.920356775568307, 2.601755382994217, 3.137724954242074, 3.492216755661169, 3.637790463304735, 3.559154476945223, 
					3.256238629730848, 2.745828231214056, 2.060868051529824, 1.247168277875622, 3.581839795584861, -5.507695437454184, -1.427491281740545, 
					-2.226265629197935, -2.909557835503155, -3.448438901992979, -3.822286485886136, -4.018224939029018, -4.030602830881330, -3.860648137594229]
					
var arrayY:Array = [-1.454175797163264, -2.194515989140971, -2.836997689438963, -3.350753439856964, -3.709494602501111, -3.892768342802582, -3.887155865669306, 
					-3.687380763975881, -3.297310791535105, -2.730819029575543, -2.012400687359314, -1.177316032122898, -2.708812838094317, 6.535513004786278, 
					1.538253370136056, 2.326300567917468, 2.967469022994209, 3.423493151126519, 3.671355113235503, 3.703974069814006, 3.528613333805134, 
					3.163954277117283, 2.636857090516239, 1.979507958032463, 1.227241954124127, 4.170250524520191, -4.135794310372972, -1.227181757022185]
					
var arrayZ:Array = [-9.497495527614323, -1.658447286107906, -2.291454449763673, -2.818599114238098, -3.213422015268945, -3.454385701423546, -3.526045524333676, 
					-3.420152960553263, -3.136677128095427, -2.684718835117025, -2.083232299955588, -1.361355856049728, -5.580098055589702, 2.796739439086039, 
					1.099438276967082, 1.848469164187886, 2.478788837042035, 2.952271001625697, 3.244025004262537, 3.343471592796725, 3.253289381637995, 
					2.987026137906393, 2.566290195350186, 2.018185787901736, 1.373297135014953, 6.642435810090652, -7.532733952310682, -8.114966437661940]

# Arrays hold the power to which the above arrays must be multiplied to e.g. 5 = -3.78x10^5 OR -3.78E+05
var powX:Array = [5, 5, 5, 5, 5, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5]
var powY:Array = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 5]
var powZ:Array = [3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 3]

# Scaling value for the distances, 2500 times smaller for the user experience
var scaleVal:int = 2500

# Positions for start and target
var start_pos:Vector3
var target_pos:Vector3

# Simulation time frame, 1 second is equal to 1 day
var simTimeFrame:float = 1.0
var elapsed_time:float = 0.0

# All array index
var i:int = 0

# Total time elapsed
var total_time:float = 0


# Called when the node enters the scene tree for the first time.
# Calculate and set staring position and calculate the target position
func _ready() -> void:
	start_pos = calculate_Target_Vector()
	global_position = start_pos
	i += 1
	target_pos = calculate_Target_Vector()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta):
	# Debug information
	DebugDraw2D.set_text("X", global_position.x)
	DebugDraw2D.set_text("Y", global_position.y)
	DebugDraw2D.set_text("Z", global_position.z)
	DebugDraw2D.set_text("Elapsed Time", elapsed_time)
	DebugDraw2D.set_text("Total elapsed time", total_time)
	
	# Move the object to the target position from the starting position over 1 second
	# Once moved to target, increase array index, set start position to current position, recalculate target and continue moving
	if elapsed_time < simTimeFrame:
		elapsed_time += delta
		total_time += delta
		var weight = elapsed_time / simTimeFrame
		global_position = start_pos.lerp(target_pos, weight)
	else:
		if i < powX.size() - 2:
			i += 1
			elapsed_time = 0.0
			start_pos = global_position
			target_pos = calculate_Target_Vector()
			
		else:
			i = 0
			elapsed_time = 0.0
			start_pos = global_position
			target_pos = calculate_Target_Vector()


# Calculate the Target Vector3 value using the X Y Z scaled into the simulation
func calculate_Target_Vector():
	return Vector3((arrayX[i] * pow(10, powX[i])) / scaleVal, (arrayY[i] * pow(10, powY[i])) / scaleVal, (arrayZ[i] * pow(10, powZ[i])) / scaleVal)
