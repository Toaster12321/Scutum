class_name EnemyStateHurt extends EnemyState

@export var knockback_speed : float = 500.0 #how fast enemy gets pushed back
@export var decelerate_speed : float = 10.0 #velocity decrease speed

var _damage_position : Vector2
var _animation_finished : bool = false
var _direction : Vector2
var _normalized_direction : Vector2

func init() -> void: 
	enemy.enemy_damaged.connect( _on_enemy_damaged ) # connect enemy damaged signal
	pass


func enter() -> void:
	enemy.invulnerable = true #make enemy invulnerable to multiple hits during animation
	_animation_finished = false 
	
	_direction = enemy.global_position.direction_to( _damage_position ) #get direction based on global position of damage position
	
	if _direction.x > 0: #normalize direction into left and right instead of floats
		_normalized_direction = Vector2.RIGHT
	else:
		_normalized_direction = Vector2.LEFT
	
	enemy.set_direction( _normalized_direction ) #set direction to face the attacking knight
	enemy.velocity = _direction * -knockback_speed #push enemy backward
	
	enemy.animation_player.play("hurt") #play hurt animation 
	enemy.animation_player.animation_finished.connect( _on_animation_finished ) #connect to animation finished function when anim is done
	pass


func exit() -> void: 
	enemy.invulnerable = false #no longer invulnerable 
	enemy.animation_player.animation_finished.disconnect( _on_animation_finished ) #disconnect signal
	pass


func process( _delta : float ) -> EnemyState:
	if _animation_finished == true:  #return the attack state when animation is over
		return attack #retaliate
	enemy.update_velocity( 0, decelerate_speed ) #deceleration speed
	return null


func physics_process( _delta : float ) -> EnemyState:
	if not enemy.is_on_floor():
		return wander
	return null


func _on_enemy_damaged( hurtbox : Hurtbox ) -> void: #when enemy damaged signal is connected
	_damage_position = hurtbox.global_position #get position vector of the hurtbox
	state_machine.change_state( self ) # change state to hurt
	pass


func _on_animation_finished( _anim : String ) -> void: 
	_animation_finished = true #set animation finished to true so enemy can be hit again
	pass
