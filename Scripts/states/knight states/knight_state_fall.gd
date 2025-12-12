class_name KnightStateFall extends KnightState

@export var fall_gravity_multipler : float = 1.165 #makes the gravity on falling slightly faster
@export var base_move_speed : float = 100
@export var acceleration : float = 8 #how fast player can accel/deaccelerate
@export var coyote_time : float = 0.1 #gives player a grace period to jump after they leave the ground

var coyote_timer : float
var move_speed : float

func init() -> void:
	pass


func enter() -> void: #on fall state enter
	knight.animation_player.play("fall") #play animation
	move_speed = maxf( base_move_speed, abs( knight.velocity.x ) ) #move speed range from base to jump + speed( adds move speed while sprinting to our base move speed)
	knight.gravity_multiplier = fall_gravity_multipler #update gravity multiplier in player script
	
	coyote_timer = coyote_time #set coyote timer
	if state_machine.previous_state == jump: #remove coyote time if last state was jump to prevent double jump
		coyote_time = 0
	pass


func exit() -> void:
	knight.gravity_multiplier = 1.0 #reset gravity mult
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if knight.knight_state_machine.input_enabled:
		if coyote_timer > 0: #if there is coyote time jump is still possible despite location
			if _event.is_action_pressed("jump"):
				return jump
		elif _event.is_action_pressed("attack"):
			return attack
	return null


func process( _delta : float ) -> KnightState:
	return null


func physics_process( _delta : float ) -> KnightState:
	coyote_timer -= _delta #count down timer
	knight.update_velocity( direction.x * move_speed, acceleration )#update our velocity in this state with direction, move speed at a delta of acceleration
	
	if knight.is_on_floor():#update to idle state if on floor
		return idle
	return null
