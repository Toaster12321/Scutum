extends Control

@onready var button_save: Button = $HBoxContainer/Button_Save
@onready var button_load: Button = $HBoxContainer/Button_Load
@onready var system: Control = $"."

func _ready() -> void:
	button_save.pressed.connect( _on_save_pressed )
	button_load.pressed.connect( _on_load_pressed )


func _on_save_pressed() -> void:
	GlobalSaveManager.save_game()


func _on_load_pressed() -> void:
	GlobalSaveManager.load_game()
	await GlobalLevelManager.level_load_started
	PauseMenu.hide_pause_menu()
