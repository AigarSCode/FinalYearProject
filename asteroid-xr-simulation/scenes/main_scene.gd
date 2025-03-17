extends Node3D

var xr_interface: XRInterface

func _ready() -> void:
	init_XR()
	pass


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
		if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
		elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	get_window().set_current_screen(1)
	
	get_viewport().transparent_bg = true
	$WorldEnvironment.environment.background_mode = Environment.BG_CLEAR_COLOR
	$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	get_window().set_current_screen(1)
