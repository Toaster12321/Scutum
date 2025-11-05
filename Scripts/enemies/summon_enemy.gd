class_name SummonEnemy extends CharacterBody2D

signal direction_changed( new_direction : Vector2 )

var direction : Vector2 = Vector2.ZERO
var facing_direction : float = 1
var move_speed : float = 70.0
var finding_player : bool = false

@onready var sprite: Node2D = $SummonNode
@onready var hitbox: Hitbox = $Hitbox
@onready var summon_animation_player: AnimationPlayer = $SummonAnimationPlayer
@onready var summon_effect_animation_player: AnimationPlayer = $SummonEffectAnimationPlayer

func _ready() -> void:
	hitbox.damaged.connect( _on_damage_taken )
	summon_animation_player.play("appear")
	await summon_animation_player.animation_finished
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	find_player()
	pass


func _process(_delta: float) -> void:
	move_and_slide()
	if finding_player == true:
		velocity = position.direction_to(GlobalPlayerManager.knight.global_position) * move_speed
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


func _on_damage_taken( _hurtbox : Hurtbox ) -> void:
	finding_player = false
	summon_effect_animation_player.play("flash")
	summon_animation_player.play("death")
	velocity = Vector2.ZERO
	
	await summon_animation_player.animation_finished
	queue_free()
	pass


func find_player() -> void:
	summon_animation_player.play("fly")
	finding_player = true
	pass
