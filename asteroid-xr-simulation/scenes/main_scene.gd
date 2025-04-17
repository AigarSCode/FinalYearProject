extends Node3D

var xr_interface: XRInterface

var current_date = Time.get_datetime_string_from_system()

func _ready() -> void:
	# Enable XR Passthrough
	init_XR()


# XR Initialisation code by Bryan Duggan 
# https://github.com/skooter500/GE1-2024/blob/main/games-engines-2024/music_toys.gd
func init_XR() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")
		
		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		var modes = xr_interface.get_supported_environment_blend_modes()
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	get_viewport().transparent_bg = true
	$WorldEnvironment.environment.background_mode = Environment.BG_CLEAR_COLOR
	$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
