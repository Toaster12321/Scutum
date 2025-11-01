class_name Messor extends CharacterBody2D

const SUMMON_SCENE : PackedScene = preload("res://Scenes/enemies/summon_enemy.tscn")

signal direction_changed( new_direction : Vector2 )

@export var max_hp : int = 10
@export var move_speed : float = 50.0

var hp : int = 10
var direction : Vector2 = Vector2.ZERO
var facing_direction : float = 1
var finding_player : bool = false

@onready var hitbox: Hitbox = $BossNode/Hitbox
@onready var hurtbox: Hurtbox = $BossNode/Hurtbox
@onready var boss_animation_player: AnimationPlayer = $BossNode/BossAnimationPlayer
@onready var boss_effect_animation_player: AnimationPlayer = $BossNode/BossEffectAnimationPlayer
@onready var sprite: Node2D = $BossNode
@onready var vision_area: VisionArea = $BossNode/VisionArea


func _ready() -> void:
	vision_area.player_enetered.connect( _on_knight_entered )
	
	hp = max_hp #set boss hp to full
	
	hitbox.damaged.connect( _on_damage_taken )
	
	find_player()
	pass


func _process(delta: float) -> void:
	velocity.y += 980 * delta 
	move_and_slide()
	
	if finding_player == true:
		
		velocity = position.direction_to(GlobalPlayerManager.knight.global_position) * move_speed


func _on_damage_taken( _hurtbox : Hurtbox ) ->  void:
	if boss_effect_animation_player.current_animation == "flash" or _hurtbox.damage == 0: #gives i frames to boss when hit
		return
	hp = clampi( hp - _hurtbox.damage, 0, max_hp) #clamp hp so hp cant fall lower than 0
	boss_effect_animation_player.play("flash")
	boss_effect_animation_player.seek( 0 ) #set to first frame and queue default just in case
	boss_effect_animation_player.queue("default")
	
	if hp < 1:
		boss_defeated()
		


func boss_defeated() -> void:
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
	boss_animation_player.play("idle")
	finding_player = true
	pass


func set_direction( _new_direction : Vector2 ) -> void:
	if _new_direction != Vector2.ZERO: #if we arent idle set direction to passed in
		direction = _new_direction
	
		if direction.x < 0: #since sprite starts left side we flip logic
			sprite.scale.x = 1   #if we are facing left flip to right
			facing_direction = -1
		elif direction.x > 0: 
			sprite.scale.x = -1 #if we are facing right flip to left
			facing_direction = 1
	
	direction_changed.emit( direction ) #emit signal for direction changed to switch any nodes to new direction


func _on_knight_entered() -> void:
	finding_player = false
	velocity = Vector2.ZERO
	pass
