class_name Messor extends CharacterBody2D

const SUMMON_SCENE : PackedScene = preload("res://Scenes/enemies/summon_enemy.tscn")

signal direction_changed( new_direction : Vector2 )

@export var max_hp : int = 10
@export var move_speed : float = 50.0

var hp : int = 10
var direction : Vector2 = Vector2.ZERO
var facing_direction : float = 1
var finding_player : bool = false
var player_seen : bool = false
var attack_select : int

@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer
@onready var boss_effect_animation_player: AnimationPlayer = $BossEffectAnimationPlayer
@onready var sprite: Node2D = $BossNode
@onready var cast_shadow: ClassShadow = $BossNode/BossSprite/CastShadow
@onready var vision_area: VisionArea = $BossNode/VisionArea


func _ready() -> void:
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	vision_area.player_enetered.connect( _on_knight_entered )
	vision_area.player_exited.connect( _on_knight_exited )
	
	hp = max_hp #set boss hp to full
	
	hitbox.damaged.connect( _on_damage_taken )
	
	find_player()
	pass


func _process(delta: float) -> void:
	attack_select = randi_range(0,2)
	velocity.y += 980 * delta 
	move_and_slide()
	
	if finding_player == true:
		
		velocity = position.direction_to(GlobalPlayerManager.knight.global_position) * move_speed


func _on_damage_taken( _hurtbox : Hurtbox ) ->  void:
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	if boss_effect_animation_player.current_animation == "flash" or _hurtbox.damage == 0: #gives i frames to boss when hit
		return
	hp = clampi( hp - _hurtbox.damage, 0, max_hp) #clamp hp so hp cant fall lower than 0
	boss_effect_animation_player.play("flash")
	boss_effect_animation_player.seek( 0 ) #set to first frame and queue default just in case
	boss_effect_animation_player.queue("default")
	
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
	await get_tree().create_timer(0.8).timeout
	
	find_player()
	pass


func _on_knight_exited():
	player_seen = false


func anim_direction() -> String: #returns a left or right based on the current direction of the player
	if direction.x < 0:
		return "left"
	else:
		return "right"
