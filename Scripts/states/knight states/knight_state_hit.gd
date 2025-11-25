class_name KnightStateHit extends KnightState

@export var knockback_speed : float = 200.0 #knockback speed when hit
@export var decelerate_speed : float = 10.0 #how fast velocity slows
@export var invulnerable_duration : float = 1.0 #invincible for 1s by default
@export var hit_audio : AudioStream
@export var hit_volume : float

var hurtbox : Hurtbox
var _normalized_direction : Vector2
var _anim_finished : bool = false
var _difference : float


func init() -> void:
	knight.player_damaged.connect( _player_damaged ) #connect function for when player is damaged
	pass


func enter() -> void:
	_anim_finished = false #animation not finished
	
	knight.audio.pitch_scale = randf_range( 0.9, 1.1 ) #make different pitch each swing
	knight.audio.volume_db = hit_volume
	knight.play_audio( hit_audio )
	
	knight.animation_player.animation_finished.connect( _animation_finished ) #connect function for when animation is finished
	
	#difference from enemy position to knight position
	_difference = knight.global_position.x - hurtbox.global_position.x
	
	if _difference > 0 and knight.facing_direction < 0: #normalize direction into left and right instead of floats
		_normalized_direction = Vector2.RIGHT
	elif _difference < 0 and knight.facing_direction > 0:
		_normalized_direction = Vector2.LEFT
	else:
		_normalized_direction = Vector2(knight.facing_direction, 0)
	
	if abs(_difference) < 8.0:# Very close or above → just keep facing 
		_normalized_direction = Vector2(knight.facing_direction, 0)
	
	#_direction = knight.global_position.direction_to(hurtbox.global_position)
	#knight.velocity = -(_direction) * -knockback_speed #knight knockback speed
	
	#knight.update_direction( _normalized_direction.x ) #update knight's facing direction
	
	knight.animation_player.play("hit") #play hit + damaged animations and start i-frames
	knight.make_invulnerable( invulnerable_duration )
	knight.effect_animation_player.play("damaged")
	
	#camera shake?
	pass


func exit() -> void:
	knight.animation_player.animation_finished.disconnect( _animation_finished ) #disconnect function
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	return null


func process( _delta : float ) -> KnightState:
	knight.velocity -= knight.velocity * decelerate_speed * _delta #decrease player velocity 
	
	if _anim_finished != false: #if the animation has finished return eitehr fall or idle
		if knight.is_on_floor() == false:
			return fall
		else:
			return idle
	return null


func physics_process( _delta : float ) -> KnightState:
	return null


func _player_damaged( _hurtbox : Hurtbox ) -> void:
	hurtbox = _hurtbox  #get passed hurtbox
	if knight.hp <= 0:
		state_machine.change_state( death )
	else:
		state_machine.change_state( self ) #change state to hurt
	pass


func _animation_finished( _anim : String ) -> void:
	if knight.hp <= 0:
		state_machine.change_state( death )
	_anim_finished = true
