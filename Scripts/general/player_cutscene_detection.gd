class_name PlayerCutsceneDetection extends Area2D

@export var knight_automove_target : Sprite2D
@export var boss_signal : CharacterBody2D
@export var boss_cutscene_detection : bool
@export var intro_cutscene_detection : bool
@export var boss_music : AudioStream

@onready var barred_gateway_1: Node2D = $"../BarredGateway"
@onready var barred_gateway_2: Node2D = $"../BarredGateway2"

signal knight_in_position #emits when knight has reached the target
signal cutscene_finished

var has_player_entered_area : bool = false

func _ready() -> void:
	if boss_cutscene_detection:
		boss_signal.boss_dead.connect(_on_boss_dead) #connect boss dead signal
		barred_gateway_1.visible = false #turn off gateways
		barred_gateway_2.visible = false
		for tilemap in barred_gateway_1.get_children():
			if tilemap is TileMapLayer:
				tilemap.collision_enabled = false
		for tilemap in barred_gateway_2.get_children():
			if tilemap is TileMapLayer:
				tilemap.collision_enabled = false
	
	if knight_automove_target: #hide target
		knight_automove_target.visible = false
	area_entered.connect( _on_area_entered )
	cutscene_finished.connect(_on_cutscene_finished)


func _on_area_entered( area : Area2D ) -> void:
	if area is InteractArea: 
		if has_player_entered_area == false: #make it so we can only enter the area once
			has_player_entered_area = true
			
			if boss_cutscene_detection:
				play_boss_cutscene() 
			if intro_cutscene_detection and not GlobalSaveManager.has_seen_intro():
				play_intro_cutscene()
			
	pass


func play_boss_cutscene() -> void:
	GlobalAudioManager.play_music(boss_music)
	GlobalPlayerManager.knight.knight_state_machine.input_enabled = false #disable input for duration of cutscene
	
	await _move_knight_to_position(knight_automove_target.global_position) #wait until knight is in position then emit signal
	knight_in_position.emit()
	
	await boss_signal.cutscene_finished
	GlobalPlayerManager.knight.knight_state_machine.input_enabled = true 
	pass


func _move_knight_to_position(target_pos:Vector2) -> void:
	while not GlobalPlayerManager.knight.is_on_floor(): #prevent running in air if jumping in cutscene area
		await get_tree().physics_frame
		
	var move_speed : float = 100
	GlobalPlayerManager.knight.animation_player.play("run")
	
	while GlobalPlayerManager.knight.global_position.distance_to(target_pos) > 4: #while we arent in position
		var dir : Vector2 =  GlobalPlayerManager.knight.global_position.direction_to( target_pos )
		dir.y = 0
		 #get direction to position and move towards it
		GlobalPlayerManager.knight.update_direction(dir.x)
		GlobalPlayerManager.knight.velocity = dir * move_speed
		await get_tree().process_frame
	
	#sit at target till told otherwise
	GlobalPlayerManager.knight.velocity = Vector2.ZERO
	GlobalPlayerManager.knight.animation_player.play("idle")
	
	#turn on barred gateways
	barred_gateway_1.visible = true
	barred_gateway_2.visible = true
	for tilemap in barred_gateway_1.get_children():
		if tilemap is TileMapLayer:
			tilemap.collision_enabled = true
	for tilemap in barred_gateway_2.get_children():
		if tilemap is TileMapLayer:
			tilemap.collision_enabled = true
	pass


func _on_boss_dead() -> void:
	#open gateways up
	barred_gateway_1.queue_free()
	barred_gateway_2.queue_free()


func play_intro_cutscene() -> void:
	KnightHud.visible = false
	GlobalSaveManager.save_game()
	
	while not GlobalPlayerManager.knight.is_on_floor():
		await get_tree().physics_frame
	
	GlobalPlayerManager.knight.animation_player.play("intro_cutscene")
	
	await GlobalPlayerManager.knight.animation_player.animation_finished
	
	cutscene_finished.emit()
	
	GlobalPlayerManager.knight.animation_player.play("idle")
	
	GlobalPlayerManager.knight.knight_state_machine.input_enabled = true
	KnightHud.visible = true
	pass


func _on_cutscene_finished() -> void:
	GlobalSaveManager.mark_intro_seen()
	
	pass
