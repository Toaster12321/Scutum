class_name Checkpoint extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_player_entered_area : bool = false

func _ready() -> void:
	area_2d.area_entered.connect( _on_area_entered )
	pass


func _on_area_entered( area : Area2D ) -> void:
	if area is InteractArea: 
		if has_player_entered_area == false: #make it so we can only enter the area once
			has_player_entered_area = true
			trigger_checkpoint()
	pass


func trigger_checkpoint() -> void:
	GlobalSaveManager.save_game()
	animation_player.play("checkpoint_reached")
	pass
