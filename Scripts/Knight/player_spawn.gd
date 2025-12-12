extends Node2D

func _ready() -> void:
	visible = false #on start hide sprite
	if GlobalPlayerManager.knight_spawned == false: #if we haven't spawned in spawn knight at location set
		GlobalPlayerManager.set_player_position( global_position )
		GlobalPlayerManager.knight_spawned = true
	
