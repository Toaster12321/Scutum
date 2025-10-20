extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var button_resume: Button = $Control/Pause/PauseButtons/Button_Resume
@onready var button_options: Button = $Control/Pause/PauseButtons/Button_Options
@onready var button_quit: Button = $Control/Pause/PauseButtons/Button_Quit
@onready var quit_yes_button: Button = $Control/QuitConfirmation/HBoxContainer/QuitYesButton
@onready var quit_no_button: Button = $Control/QuitConfirmation/HBoxContainer/QuitNoButton
@onready var quit_confirmation: Control = $Control/QuitConfirmation
@onready var pause_buttons: VBoxContainer = $Control/Pause/PauseButtons

var is_paused : bool = false

func _ready() -> void:
	hide_pause_menu() #hide pause UI
	quit_confirmation.visible = false
	button_resume.pressed.connect( _on_resume_pressed ) #connect button functions
	button_quit.pressed.connect( _on_quit_pressed )
	quit_yes_button.pressed.connect( _on_quit_yes_pressed )
	quit_no_button.pressed.connect( _on_quit_no_pressed )
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled() #set the viewport event as handled tpo not be processed by other nodes
	pass


func hide_pause_menu() -> void:
	get_tree().paused = false #unpause game
	visible = false
	is_paused = false
	hidden.emit() #emit UI hidden signal
	pass


func show_pause_menu() -> void:
	get_tree().paused = true #pause game
	visible = true
	is_paused = true
	shown.emit() #emit UI shown signal
	pass


func _on_resume_pressed() -> void:
	hide_pause_menu()
	pass


func _on_quit_pressed() -> void:
	pause_buttons.process_mode = Node.PROCESS_MODE_DISABLED #disable normal pause menu buttons
	quit_confirmation.visible = true #show confimation
	pass


func _on_quit_yes_pressed() -> void:
	get_tree().quit()
	pass


func _on_quit_no_pressed() -> void:
	quit_confirmation.visible = false #reenable normal pause buttons
	pause_buttons.process_mode = Node.PROCESS_MODE_ALWAYS
	pass
