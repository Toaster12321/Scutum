class_name EnemyStateDeath extends EnemyState

@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@export var is_flying_enemy : bool = false
@export var effect_animations : AnimationPlayer

@onready var vision_area: VisionArea = %VisionArea

var _damage_position : Vector2
var _direction : Vector2
var gravity : float = 200

func init() -> void:
	enemy.enemy_destroyed.connect( _on_enemy_destroyed ) #connect to on enemy destroyed function when enemy destroyed signal has been triggered
	pass


func enter() -> void:
	#print("death entered")
	
	vision_area.monitoring = false
	enemy.invulnerable = true #cant be hit when dead
	_direction = enemy.global_position.direction_to( _damage_position ) #get direction based on global position of damage position
	
	enemy.set_direction( _direction ) #set direction to face the attacking knight
	enemy.velocity = _direction * -knockback_speed #push enemy backwards
	
	if enemy.enemy_type == enemy.EnemyType.WARRIOR:
		effect_animations.play("flash")
	enemy.animation_player.play("death") #play hurt animation 
	enemy.animation_player.animation_finished.connect( _on_death_animation_finished ) #connect to animation finished function when anim is done
	disable_hurt_box() #disable enemy's hurtbox
	pass


func exit() -> void:
	#print("death exited")
	pass


func process( _delta : float ) -> EnemyState:
	if is_flying_enemy == false:
		enemy.velocity -= enemy.velocity * decelerate_speed * _delta #deceleration of velocity
	else:
		if enemy.is_on_floor() == false:
			enemy.velocity.y += gravity * _delta
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null


func _on_enemy_destroyed( hurtbox : Hurtbox) -> void: #when enemy damaged signal is connected
	_damage_position = hurtbox.global_position #get position vector of the hurtbox
	state_machine.change_state( self ) #change state to death
	pass


func disable_hurt_box() -> void:
	var hurtbox : Hurtbox = enemy.get_node_or_null("Hurtbox") #get the hurtbox node on the enemy
	if hurtbox: #if they have one disable the monitoring
		hurtbox.monitoring = false


func _on_death_animation_finished( _anim : String ) -> void:
	enemy.queue_free() #at the end of the animation queue free the enemy
	pass
