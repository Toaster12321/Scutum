class_name Messor extends CharacterBody2D

const SUMMON_SCENE : PackedScene = preload("res://Scenes/enemies/summon_enemy.tscn")

signal direction_changed( new_direction : Vector2 )

@export var max_hp : int = 10
@export var move_speed : float = 50.0

var hp : int = 10
var direction : Vector2 = Vector2.ZERO
var summon_target : Vector2
var return_target : Vector2
var facing_direction : float = 1
var finding_player : bool = true
var moving_to_summon : bool = false
var returning_to_floor = false
var player_seen : bool = false
var attack_select : int
var summons : Array[Node2D]

@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer
@onready var boss_effect_animation_player: AnimationPlayer = $BossEffectAnimationPlayer
@onready var sprite: Node2D = $BossNode
@onready var cast_shadow: ClassShadow = $BossNode/BossSprite/CastShadow
@onready var vision_area: VisionArea = $BossNode/VisionArea


func _ready() -> void:
	$SummoningPositions.visible = false
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	vision_area.player_enetered.connect( _on_knight_entered )
	vision_area.player_exited.connect( _on_knight_exited )
	
	hp = max_hp #set boss hp to full
	
	hitbox.damaged.connect( _on_damage_taken )
	
	find_player()
	pass


func _process(delta: float) -> void:
	attack_select = randi_range(0,2)
	move_and_slide()
	
	if finding_player == true: 
		velocity.y += 980 * delta
		velocity = position.direction_to(GlobalPlayerManager.knight.global_position) * move_speed
	
	if moving_to_summon == true:
		hitbox.monitorable = false
		vision_area.monitoring = false
		finding_player = false
		var summon_spot = get_tree().current_scene.get_node("BossSummonPosition")
		if summon_spot:
			summon_target = summon_spot.global_position
			velocity = position.direction_to(summon_target) * move_speed
		
		if global_position.distance_to(summon_target) < 1.0:
			moving_to_summon = false
			velocity = Vector2.ZERO
			summon()
	
	if returning_to_floor == true:
		hitbox.monitorable = true
		vision_area.monitoring = true
		var return_spot = get_tree().current_scene.get_node("BossReturnPosition")
		if return_spot:
			return_target = return_spot.global_position
			velocity = position.direction_to(return_target) * move_speed
		
		if global_position.distance_to(return_target) < 1.0:
			returning_to_floor = false
			find_player()


func _on_damage_taken( _hurtbox : Hurtbox ) ->  void:
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	if boss_effect_animation_player.current_animation == "flash" or _hurtbox.damage == 0: #gives i frames to boss when hit
		return
	hp = clampi( hp - _hurtbox.damage, 0, max_hp) #clamp hp so hp cant fall lower than 0
	boss_effect_animation_player.play("flash")
	boss_effect_animation_player.seek( 0 ) #set to first frame and queue default just in case
	boss_effect_animation_player.queue("default")
	
	if hp == 7 or hp == 3:
		boss_animation_player.play("idle")
		moving_to_summon = true
	
	if hp < 1:
		boss_defeated()
		


func boss_defeated() -> void:
	cast_shadow.queue_free()
	boss_animation_player.play("death")
	set_hit_boxes(false)
	
	await boss_animation_player.animation_finished
	
	queue_free()
	pass


func set_hit_boxes( _bool : bool = true ) -> void:
	hitbox.set_deferred("monitorable", _bool)
	hurtbox.set_deferred("monitoring", _bool)
	pass


func find_player() -> void:
	if player_seen == true:
		_on_knight_entered()
		return
		
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	boss_animation_player.play("idle")
	finding_player = true
	pass


func set_direction( _new_direction : Vector2 ) -> void:
	if _new_direction != Vector2.ZERO: 
		direction = _new_direction
	
		if direction.x < 0: 
			sprite.scale.x = -1 #if we are facing right flip left
			facing_direction = 1
		elif direction.x > 0: 
			sprite.scale.x = 1 #if we are facing left flip right
			facing_direction = -1
	
	direction_changed.emit( direction ) #emit signal for direction changed to switch any nodes to new direction


func _on_knight_entered() -> void:
	player_seen = true
	finding_player = false
	velocity = Vector2.ZERO
	
	match attack_select:
		0:
			boss_animation_player.play("double_attack_" + anim_direction())
		1:
			boss_animation_player.play("single_attack_" + anim_direction())
		2:
			boss_animation_player.play("skill")
	
	await boss_animation_player.animation_finished
	boss_animation_player.play("idle2")
	await get_tree().create_timer(1).timeout
	
	find_player()
	pass


func _on_knight_exited():
	player_seen = false


func anim_direction() -> String: #returns a left or right based on the current direction of the player
	if direction.x < 0:
		return "left"
	else:
		return "right"


func summon() -> void:
	boss_animation_player.stop()
	boss_animation_player.play("summon")
	for c in $SummoningPositions.get_children():
		summons.append(c)
	
	if summons.size() == 0: 
		print("no positions found")
	
	var summon1 : Node2D = SUMMON_SCENE.instantiate() #instatiate summons
	var summon2 : Node2D = SUMMON_SCENE.instantiate()
	var summon3 : Node2D = SUMMON_SCENE.instantiate()
	
	get_parent().add_child.call_deferred( summon1 ) #add spells as a child to the enemy
	get_parent().add_child.call_deferred( summon2 )
	get_parent().add_child.call_deferred( summon3 )
	
	summon1.global_position = summons[0].global_position #set their position to the indicator set in editor
	summon2.global_position = summons[1].global_position
	summon3.global_position = summons[2].global_position
	
	await boss_animation_player.animation_finished
	boss_animation_player.play("idle2")
	returning_to_floor = true
	moving_to_summon = false
	pass
