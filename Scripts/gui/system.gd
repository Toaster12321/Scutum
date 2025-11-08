extends Control

@onready var button_save: Button = $HBoxContainer/Button_Save
@onready var button_load: Button = $HBoxContainer/Button_Load
@onready var system: Control = $"."
@onready var save_confirmation: Control = $"../SaveConfirmation"
@onready var save_yes_button: Button = $"../SaveConfirmation/HBoxContainer/SaveYesButton"
@onready var save_no_button: Button = $"../SaveConfirmation/HBoxContainer/SaveNoButton"

func _ready() -> void:
	save_confirmation.visible = false
	button_save.pressed.connect( _on_save_pressed )
	button_load.pressed.connect( _on_load_pressed )
	save_yes_button.pressed.connect( _on_save_yes_pressed )
	save_no_button.pressed.connect( _on_save_no_pressed )


func _on_save_pressed() -> void:
	button_save.disabled = true
	button_load.disabled = true
	
	save_confirmation.visible = true
	save_no_button.grab_focus()


func _on_save_yes_pressed() -> void:
	button_save.disabled = false
	button_load.disabled = false
	
	save_confirmation.visible = false
	GlobalSaveManager.save_game()
	PauseMenu.hide_pause_menu()


func _on_save_no_pressed() -> void:
	button_save.disabled = false
	button_load.disabled = false 
	
	save_confirmation.visible = false
	


func _on_load_pressed() -> void:
	GlobalSaveManager.load_game()
	await GlobalLevelManager.level_load_started
	PauseMenu.hide_pause_menu()
