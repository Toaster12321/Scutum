extends CanvasLayer

signal shown
signal hidden

var resolutions = {
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

@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var button_resume: Button = $Control/Pause/PauseButtons/Button_Resume
@onready var button_options: Button = $Control/Pause/PauseButtons/Button_Options
@onready var button_quit: Button = $Control/Pause/PauseButtons/Button_Quit
@onready var quit_yes_button: Button = $Control/QuitConfirmation/HBoxContainer/QuitYesButton
@onready var quit_no_button: Button = $Control/QuitConfirmation/HBoxContainer/QuitNoButton
@onready var quit_confirmation: Control = $Control/QuitConfirmation
@onready var pause_buttons: VBoxContainer = $Control/Pause/PauseButtons
@onready var options_menu: Control = $Control/Options
@onready var pause_menu: Control = $Control/Pause

var is_paused : bool = false

func _ready() -> void:
	hide_pause_menu() #hide pause UI
	quit_confirmation.visible = false
	options_menu.visible = false
	button_resume.pressed.connect( _on_resume_pressed ) #connect button functions
	button_quit.pressed.connect( _on_quit_pressed )
	button_options.pressed.connect( _on_options_pressed )
	quit_yes_button.pressed.connect( _on_quit_yes_pressed )
	quit_no_button.pressed.connect( _on_quit_no_pressed )
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
			var options_menu = get_node("Control/Options")
			options_menu.update_button_values()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled() #set the viewport event as handled tpo not be processed by other nodes
	pass


func hide_pause_menu() -> void:
	get_tree().paused = false #unpause game
	_reset_menu()
	visible = false
	is_paused = false
	hidden.emit() #emit UI hidden signal
	pass


func show_pause_menu() -> void:
	pause_buttons.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true #pause game
	pause_menu.visible = true
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

func _on_options_pressed() -> void:
	pause_menu.visible = false
	options_menu.visible = true
	pass

func _on_quit_yes_pressed() -> void:
	get_tree().quit()
	pass


func _on_quit_no_pressed() -> void:
	quit_confirmation.visible = false #reenable normal pause buttons
	pause_buttons.process_mode = Node.PROCESS_MODE_ALWAYS
	pass


func _reset_menu() -> void:
	options_menu.visible = false
	quit_confirmation.visible = false
	pass


func center_window():
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size /2)
