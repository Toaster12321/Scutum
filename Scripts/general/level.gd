class_name Level extends Node2D

@export var level_music : AudioStream
@export var player_cutscene_detection : PlayerCutsceneDetection

func _ready() -> void:
	GlobalPlayerManager.set_as_parent( self ) #makes it so player node is not deleted
	GlobalLevelManager.level_load_started.connect( _free_level ) #frees old level
	GlobalAudioManager.play_music( level_music ) #plays level music
	


func _free_level() -> void:
	GlobalPlayerManager.unparent_player( self )
	queue_free()
