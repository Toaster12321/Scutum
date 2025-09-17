extends Node

const START_LEVEL : String = "res://Scenes/levels/level_1.tscn"

@export var title_music : AudioStream
@export var button_focus_audio : AudioStream
@export var button_press_audio : AudioStream

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	get_tree().paused = true
	GlobalPlayerManager.knight.visible = false
	
	KnightHud.visible = false
	
	setup_title_screen()
	pass


func setup_title_screen() -> void:
	GlobalAudioManager.play_music( title_music )
	pass
