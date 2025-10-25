extends Control

@onready var res_option_button: OptionButton = $VBoxContainer2/res_OptionButton
@onready var resolution_confirmation: Control = $"../ResolutionConfirmation"
@onready var timer: Timer = $"../ResolutionConfirmation/Timer"
@onready var timer_label: Label = $"../ResolutionConfirmation/TimerLabel"
@onready var res_yes_button: Button = $"../ResolutionConfirmation/HBoxContainer/ResYesButton"
@onready var res_no_button: Button = $"../ResolutionConfirmation/HBoxContainer/ResNoButton"
@onready var options_menu: Control = $"."
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer2/FullscreenCheckbox
@onready var v_sync_check_box: CheckBox = $VBoxContainer2/VSyncCheckBox
@onready var scale_slider: HSlider = $VBoxContainer2/ScaleBox/ScaleSlider
@onready var scale_label: Label = $VBoxContainer2/ScaleBox/ScaleLabel

var resolutions : Dictionary = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}
var previous_resolution = {}

var master_bus = AudioServer.get_bus_index("Master") #audio buses
var sfx_bus = AudioServer.get_bus_index("SFX")
var music_bus = AudioServer.get_bus_index("Music")


func _ready() -> void:
	res_yes_button.pressed.connect(_on_res_yes_pressed)
	res_no_button.pressed.connect(_on_res_no_pressed)
	resolution_confirmation.visible = false
	add_resolutions() #populate dropdown resolution menu
	check_variables()


func check_variables() -> void:
	var _window = get_window()
	var mode = _window.get_mode()
	
	if mode == Window.MODE_FULLSCREEN: #if already in fullscreen check true
		fullscreen_checkbox.set_pressed_no_signal(true)
	
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED: #if vsync already enabled check true
		v_sync_check_box.set_pressed_no_signal(true)
	pass


func set_resolution_text() -> void:
	var resolution_text = str(roundi(get_window().get_size().x))+"x"+str(roundi(get_window().get_size().y))
	res_option_button.set_text(resolution_text)


func _process(_delta: float) -> void:
	timer_label.text = str(int(timer.time_left))
	pass


func _on_h_slider_value_changed(value: float) -> void: #master volume bind
	AudioServer.set_bus_volume_db( master_bus, value )
	
	if value == -30:
		AudioServer.set_bus_mute( master_bus, true)
	else:
		AudioServer.set_bus_mute( master_bus, false)
	pass


func _on_sfx_slider_value_changed(value: float) -> void: #sfx volume bind
	AudioServer.set_bus_volume_db( sfx_bus, value )
	
	if value == -30:
		AudioServer.set_bus_mute( sfx_bus, true)
	else:
		AudioServer.set_bus_mute( sfx_bus, false)
	pass # Replace with function body.



func _on_music_slider_value_changed(value: float) -> void: #music volume bind
	AudioServer.set_bus_volume_db( music_bus, value )
	
	if value == -30:
		AudioServer.set_bus_mute( music_bus, true)
	else:
		AudioServer.set_bus_mute( music_bus, false)
	pass # Replace with function body.


func add_resolutions() -> void:
	var current_resolution = get_window().get_size()
	var ID = 0
	
	for i in resolutions: #populates dropdown resolution menu
		res_option_button.add_item(i, ID)
		if resolutions[i] == current_resolution:
			res_option_button.select(ID) #if we already in a resolution select it
		ID += 1


func _on_res_option_button_item_selected(index: int) -> void: 
	options_menu.visible = false
	var key = res_option_button.get_item_text(index) #key is the index of selected item in the dropdown menu
	var res = resolutions[key]
	get_window().set_size(res)
	PauseMenu.center_window()
	
	show_resolution_confirmation()
	pass # Replace with function body.


func update_button_values():
	var window_size_string = str(get_window().size.x,"x",get_window().size.y) #gets x and y of the window
	var resolutions_index = resolutions.keys().find(window_size_string) #find the corresponding string in the array from the key
	previous_resolution = resolutions_index
	res_option_button.selected = resolutions_index #set index to the selected button


func show_resolution_confirmation() -> void:
	resolution_confirmation.visible = true
	res_no_button.grab_focus()
	timer.start()
	pass


func _on_res_yes_pressed() -> void:
	resolution_confirmation.visible = false
	options_menu.visible = true
	timer.stop()
	pass


func _on_res_no_pressed() -> void:
	timer.stop()
	var key = res_option_button.get_item_text(previous_resolution) #key is the index of previous resolution
	resolution_confirmation.visible = false #tunr off UI
	options_menu.visible = true
	get_window().set_size(resolutions[key])  #set window size to the key
	PauseMenu.center_window() #center the window so it doesnt move to a weird position
	res_option_button.selected = previous_resolution #reselect old options
	pass


func _on_timer_timeout() -> void:
	_on_res_no_pressed() #performs the same as a no press
	pass # Replace with function body.


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	res_option_button.set_disabled(toggled_on) #turn off resolution if in fullscreen
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) #set fullscreen
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)#set windowed
		PauseMenu.center_window()
	get_tree().create_timer(.05).timeout.connect(set_resolution_text)#provide processing frames for text change during window change
	pass # Replace with function body.


#func _on_scale_slider_value_changed(value: float) -> void:
	#var resolution_scale = value/100.0
	#var resolution_text = str(round(get_window().get_size().x*resolution_scale))+"x"+str(round(get_window().get_size().y*resolution_scale))
	#
	#scale_label.set_text(str(value)+"% - "+ resolution_text)
	#get_viewport().set_scaling_3d_scale(resolution_scale)
	#pass # Replace with function body.


func _on_v_sync_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	pass # Replace with function body.
