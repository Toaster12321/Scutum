class_name PlayerCutsceneDetection extends Area2D

@export var knight_automove_target : Sprite2D

signal cutscene_finished

var has_player_entered_area : bool = false

func _ready() -> void:
	if knight_automove_target:
		knight_automove_target.visible = false
	area_entered.connect( _on_area_entered )


func _on_area_entered( area : Area2D ) -> void:
	if area is InteractArea:
		if has_player_entered_area == false:
			has_player_entered_area = true
			play_boss_cutscene()
			
	pass


func play_boss_cutscene() -> void:
	GlobalPlayerManager.knight.run.input_enabled = false
	
	await _move_knight_to_position(knight_automove_target.global_position)
	
	GlobalPlayerManager.knight.run.input_enabled = true
	pass


func _move_knight_to_position(target_pos:Vector2) -> void:
	var move_speed : float = 100
	GlobalPlayerManager.knight.animation_player.play("run")
	
	while GlobalPlayerManager.knight.global_position.distance_to(target_pos) > 4:
		var dir : Vector2 =  GlobalPlayerManager.knight.global_position.direction_to( target_pos )
		dir.y = 0
		
		GlobalPlayerManager.knight.update_direction(dir.x)
		GlobalPlayerManager.knight.velocity = dir * move_speed
		await get_tree().process_frame
	
	GlobalPlayerManager.knight.velocity = Vector2.ZERO
	GlobalPlayerManager.knight.animation_player.play("idle")
	pass
