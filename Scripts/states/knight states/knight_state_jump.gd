class_name KnightStateJump extends KnightState

@export var jump_velocity : float = 400.0 #jump height
@export var base_move_speed : float = 100
@export var acceleration : float = 8 #how fast we accelerate the jump


var move_speed : float


func init() -> void:
	pass


func enter() -> void:
	knight.animation_player.play("jump") #play animation
	knight.global_position.y -= 1 #move up 1 pixel to avoid is on floor cases
	knight.velocity.y = -jump_velocity #negative is the up direction
	
	move_speed = maxf( base_move_speed, abs( knight.velocity.x ) ) #move speed range from base to jump + speed( adds move speed while sprinting to our base move speed)
	pass


func exit() -> void:
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if _event.is_action_released("jump"): # variable jump height when jump is released
		knight.velocity.y *= 0.5 # slowly decrease velocity in y direction
		return fall
	elif _event.is_action_pressed("attack"):
		if knight.attack_locked:  #prevent attacking again if cooldown is still active
			return null
		return attack
	return null


func process( _delta : float ) -> KnightState:
	return null


func physics_process( _delta : float ) -> KnightState:
	knight.update_velocity( direction.x * move_speed, acceleration)#update our velocity in this state with direction, move speed at a delta of acceleration
	
	
	if knight.is_on_floor():#update to idle state if on floor
		return idle
	elif knight.velocity.y >= 0: #when player goes down go to fall state
		return fall
	return null
