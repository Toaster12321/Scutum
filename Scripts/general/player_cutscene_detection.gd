class_name PlayerCutsceneDetection extends Area2D


signal activated()


var has_player_entered_area : bool = false

func _ready() -> void:
	area_entered.connect( _on_area_entered )


func _on_area_entered( area : Area2D ) -> void:
	if area is InteractArea:
		if has_player_entered_area == false:
			has_player_entered_area = true
			play_boss_cutscene()
			
	pass


func play_boss_cutscene() -> void:
	GlobalPlayerManager.knight.update_velocity(0, 100)
	print("in area")
	pass
