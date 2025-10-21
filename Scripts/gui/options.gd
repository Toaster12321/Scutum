extends Control

@onready var res_option_button: OptionButton = $VBoxContainer2/res_OptionButton
@onready var resolution_confirmation: Control = $"../ResolutionConfirmation"
@onready var timer: Timer = $"../ResolutionConfirmation/Timer"
@onready var timer_label: Label = $"../ResolutionConfirmation/TimerLabel"
@onready var res_yes_button: Button = $"../ResolutionConfirmation/HBoxContainer/ResYesButton"
@onready var res_no_button: Button = $"../ResolutionConfirmation/HBoxContainer/ResNoButton"

var previous_resolution = {}

var master_bus = AudioServer.get_bus_index("Master") #audio buses
var sfx_bus = AudioServer.get_bus_index("SFX")
var music_bus = AudioServer.get_bus_index("Music")


func _ready() -> void:
	res_yes_button.pressed.connect(_on_res_yes_pressed)
	res_no_button.pressed.connect(_on_res_no_pressed)
	resolution_confirmation.visible = false
	add_resolutions() #populate dropdown resolution menu

func _process(delta: float) -> void:
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
	for i in PauseMenu.resolutions: #populates dropdown resolution menu
		res_option_button.add_item(i)


func _on_res_option_button_item_selected(index: int) -> void: #
	var key = res_option_button.get_item_text(index) #key is the index of selected item in the dropdown menu
	print(previous_resolution)
	get_window().set_size(PauseMenu.resolutions[key])  #set window size to the key
	PauseMenu.center_window() #center the window so it doesnt move to a weird position
	show_resolution_confirmation()
	pass # Replace with function body.


func update_button_values():
	var window_size_string = str(get_window().size.x,"x",get_window().size.y) #gets x and y of the window
	var resolutions_index = PauseMenu.resolutions.keys().find(window_size_string) #find the corresponding string in the array from the key
	previous_resolution = resolutions_index
	res_option_button.selected = resolutions_index #set index to the selected button


func show_resolution_confirmation() -> void:
	resolution_confirmation.visible = true
	timer.start()
	pass


func _on_res_yes_pressed() -> void:
	resolution_confirmation.visible = false
	timer.stop()
	pass


func _on_res_no_pressed() -> void:
	timer.stop()
	var key = res_option_button.get_item_text(previous_resolution) #key is the index of previous resolution
	resolution_confirmation.visible = false #tunr off UI
	get_window().set_size(PauseMenu.resolutions[key])  #set window size to the key
	PauseMenu.center_window() #center the window so it doesnt move to a weird position
	res_option_button.selected = previous_resolution #reselect old options
	pass


func _on_timer_timeout() -> void:
	_on_res_no_pressed() #performs the same as a no press
	pass # Replace with function body.
