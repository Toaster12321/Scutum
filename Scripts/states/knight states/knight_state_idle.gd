class_name KnightStateIdle extends KnightState

@export var deceleration : float = 8

var input_enabled : bool = true

func init() -> void:
	pass


func enter() -> void:
	knight.animation_player.play("idle") #play animation
	pass


func exit() -> void:
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if input_enabled:
		if _event.is_action_pressed("jump"): #transition to jump state when button is pressed
			return jump
		elif _event.is_action_pressed("attack"): #transition to attack state when button is pressed
			return attack
		elif _event.is_action_pressed("shield"):
			return shield
	return null


func process( _delta : float ) -> KnightState:
	return null


func physics_process( _delta : float ) -> KnightState:
	knight.update_velocity( 0, deceleration ) #stop players velocity and acceleration
	if direction.x != 0: #if the player is holding any direction in the x axis we are running
		knight.update_direction(direction.x)
		return run
	elif direction.y > 0: #pressing the down key 
		return crouch
	elif not knight.is_on_floor(): # if we are in the air go to fall state
		return fall
	return null
