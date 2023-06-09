extends Control

@onready var confirm_box : ConfirmationDialog = $PanelContainer/ScrollContainer/VBoxContainer/SaveButton/ConfirmationDialog
@onready var quit_confirm : ConfirmationDialog = $QuitButton/QuitConfirmation
@onready var menu_confirm : ConfirmationDialog = $MainMenuButton/MenuConfirmation

var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)

var world_environment : WorldEnvironment = null
var directional_light : DirectionalLight3D = null
var voxel_gi : VoxelGI = null

var config_file = ConfigFile.new()

signal initiated
signal main_menu_request


func _on_ui_scale_slider_value_changed(value):
	var new_size = viewport_start_size * value
	get_tree().root.set_content_scale_size(new_size)


func _on_resolution_scale_slider_value_changed(value):
	get_viewport().scaling_3d_scale = value


func _on_display_filter_menu_item_selected(index):
	if index == 0:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		%FSRSharpLabel.hide()
		%FSRSharpSlider.hide()
	if index == 1:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		%FSRSharpLabel.show()
		%FSRSharpSlider.show()


func _on_fsr_sharp_slider_value_changed(value):
	get_viewport().fsr_sharpness = value


func _on_fullscreen_menu_item_selected(index):
	if index == 0:
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	if index == 1:
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)


func _on_v_sync_menu_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_taa_menu_item_selected(index):
	get_viewport().use_taa = index == 1


func _on_msaa_menu_item_selected(index):
	match index:
		0:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1:
			get_viewport().msaa_3d = Viewport.MSAA_2X
		2:
			get_viewport().msaa_3d = Viewport.MSAA_4X
		3:
			get_viewport().msaa_3d = Viewport.MSAA_8X


func _on_fxaa_menu_item_selected(index):
	if index == 0:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	if index == 1:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA


func _on_shadow_res_menu_item_selected(index):
	match index:
		0: # Very Low
			RenderingServer.directional_shadow_atlas_set_size(512, true)
			directional_light.shadow_bias = 0.06
			get_viewport().positional_shadow_atlas_size = 0
		1:
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			directional_light.shadow_bias = 0.04
			get_viewport().positional_shadow_atlas_size = 1024
		2: # Low
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			directional_light.shadow_bias = 0.03
			get_viewport().positional_shadow_atlas_size = 2048
		3: # Medium
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			directional_light.shadow_bias = 0.02
			get_viewport().positional_shadow_atlas_size = 4096
		4: # High
			RenderingServer.directional_shadow_atlas_set_size(8192, true)
			directional_light.shadow_bias = 0.01
			get_viewport().positional_shadow_atlas_size = 8192
		5: # Ultra
			RenderingServer.directional_shadow_atlas_set_size(16384, true)
			directional_light.shadow_bias = 0.005
			get_viewport().positional_shadow_atlas_size = 16384


func _on_shadow_filter_menu_item_selected(index):
	match index:
		0:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		1:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
		2:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		3:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		4:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		5:
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


func _on_voxel_gi_menu_item_selected(index):
	if index == 0:
		voxel_gi.hide()
	if index == 1:
		voxel_gi.show()


func _on_model_quality_menu_item_selected(index):
	match index:
		0:
			get_viewport().mesh_lod_threshold = 8.0
		1:
			get_viewport().mesh_lod_threshold = 4.0
		2:
			get_viewport().mesh_lod_threshold = 2.0
		3:
			get_viewport().mesh_lod_threshold = 1.0
		4:
			get_viewport().mesh_lod_threshold = 0.0


func _on_global_illum_menu_item_selected(index):
	match index:
		0:
			world_environment.environment.sdfgi_enabled = false
		1:
			world_environment.environment.sdfgi_enabled = true
			RenderingServer.gi_set_use_half_resolution(true)
		2:
			world_environment.environment.sdfgi_enabled = true
			RenderingServer.gi_set_use_half_resolution(false)


func _on_bloom_menu_item_selected(index):
	if index == 0:
		world_environment.environment.glow_enabled = false
	if index == 1:
		world_environment.environment.glow_enabled = true


func _on_amb_occ_menu_item_selected(index):
	match index:
		0:
			world_environment.environment.ssao_enabled = false
		1:
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
		2:
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
		3:
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
		4:
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)


func _on_ssr_menu_item_selected(index):
	match index:
		0:
			world_environment.environment.set_ssr_enabled(false)
		1:
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(8)
		2:
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(32)
		3:
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(56)


func _on_ssl_menu_item_selected(index):
	match index:
		0:
			world_environment.environment.ssil_enabled = false
		1:
			world_environment.environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
		2:
			world_environment.environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
		3:
			world_environment.environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
		4:
			world_environment.environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)


func _on_brightness_slider_value_changed(value):
	world_environment.environment.set_adjustment_brightness(value)


func _on_contrast_slider_value_changed(value):
	world_environment.environment.set_adjustment_contrast(value)


func _on_saturation_slider_value_changed(value):
	world_environment.environment.set_adjustment_saturation(value)


func initiate():
	world_environment = get_tree().get_first_node_in_group("WorldEnvironment")
	directional_light = get_tree().get_first_node_in_group("DirectionalLight")
	voxel_gi = get_tree().get_first_node_in_group("VoxelGI")
	load_settings()
	initiated.emit()


func save_settings():
	for child in $PanelContainer/ScrollContainer/VBoxContainer.get_children():
		if child is GridContainer:
			for node in child.get_children():
				if node is HSlider:
					config_file.set_value(child.get_path(), node.get_path(), node.value)
				elif node is OptionButton:
					config_file.set_value(child.get_path(), node.get_path(), node.get_selected_id())
	var err = config_file.save("user://settings.cfg")
	if err != OK:
		printerr("Error saving file...")
	else:
		print("Save ok!")


func load_settings():
	var err = config_file.load("user://settings.cfg")
	if err != OK:
		print("no settings to load")
		initiate_default_settings()
		pass
	else:
		for setting in config_file.get_sections():
			# Get nodes available in current GridContainer
			var keys = config_file.get_section_keys(setting)
			for key in keys:
				# Get the value to set to current setting
				var value = config_file.get_value(setting, key)
				if value < 0 or value > 5:
					printerr("couldn't obtain value" + str(setting) + " " + str(key))
				else:
					# Set value of current setting
					var current_node = get_node(key)
					if current_node is HSlider:
						current_node.value = value
					elif current_node is OptionButton:
						current_node.select(value)
						current_node.emit_signal("item_selected", value)
					else:
						print("what?")
						pass


func initiate_default_settings():
	for container in $PanelContainer/ScrollContainer/VBoxContainer.get_children():
		if container is GridContainer:
			for node in container.get_children():
				if node is HSlider:
					node.emit_signal("value_changed", node.value)
				if node is OptionButton:
					node.emit_signal("item_selected", node.selected)
	
	save_settings()


func _on_save_button_pressed():
#	save_settings()
	confirm_box.show()

func _on_confirmation_dialog_confirmed():
	save_settings()


func _on_quit_button_pressed():
	quit_confirm.show()
	
func _on_quit_confirmation_confirmed():
	get_tree().quit()


func _on_main_menu_button_pressed():
	menu_confirm.show()

func _on_menu_confirmation_confirmed():
	hide()
	main_menu_request.emit()
