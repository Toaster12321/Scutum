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
@onready var options_menu: Control = $Control/Options
@onready var pause_menu: Control = $Control/Pause
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var fade_to_black_rect: ColorRect = $Control/FadeToBlack
@onready var button_system: Button = $Control/Pause/PauseButtons/Button_System
@onready var system_menu: Control = $Control/System



var is_paused : bool = false
var on_title_screen : bool = false

func _ready() -> void:
	hide_pause_menu() #hide pause UI
	quit_confirmation.visible = false
	options_menu.visible = false
	system_menu.visible = false
	button_resume.pressed.connect( _on_resume_pressed ) #connect button functions
	button_quit.pressed.connect( _on_quit_pressed )
	button_options.pressed.connect( _on_options_pressed )
	quit_yes_button.pressed.connect( _on_quit_yes_pressed )
	quit_no_button.pressed.connect( _on_quit_no_pressed )
	button_system.pressed.connect( _on_system_pressed )
	
	GlobalLevelManager.level_loaded.connect( return_to_title )
	pass


func _unhandled_input(event: InputEvent) -> void:
	if ! on_title_screen:
		if event.is_action_pressed("pause"):
			if is_paused == false:
				show_pause_menu()
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
	button_resume.grab_focus()
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
	pause_menu.visible = false #disable normal pause menu buttons
	quit_confirmation.visible = true #show confimation
	quit_no_button.grab_focus()
	pass

func _on_options_pressed() -> void:
	pause_menu.visible = false
	options_menu.visible = true
	pass

func _on_system_pressed() -> void:
	pause_menu.visible = false
	system_menu.visible = true
	pass

func _on_quit_yes_pressed() -> void:
	await fade_to_black()
	GlobalLevelManager.load_new_level("res://Scenes/levels/title_screen.tscn", "", Vector2.ZERO) #load title screen
	pass


func _on_quit_no_pressed() -> void:
	pause_menu.visible = true
	quit_confirmation.visible = false #reenable normal pause buttons
	button_resume.grab_focus()
	pass


func fade_to_black() -> bool:
	animation_player.play("fade_to_black") #play fade to black
	await animation_player.animation_finished
	GlobalPlayerManager.knight.revive_player()#heal player to full
	return true


func _reset_menu() -> void:
	options_menu.visible = false #hide options UI
	system_menu.visible = false
	quit_confirmation.visible = false
	pass


func center_window():
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size /2)


func return_to_title() -> void:
	visible = false #turn off UI
	fade_to_black_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE #allow mouse input again
	fade_to_black_rect.color = Color(1,1,1,0) #change rect to transparent again
	pass
