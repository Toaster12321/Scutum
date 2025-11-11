class_name KnightStateRun extends KnightState

@export var move_speed : float = 100 #base speed
@export var sprint_speed : float = 150 #running speed
@export var acceleration : float = 4
@export var skid_acceleration : float = 8 #acceleration for turning player around

var current_acceleration : float 
var current_direction : float = 0
var target_speed : float
var input_enabled : bool = true


func init() -> void:
	
	pass


func enter() -> void:
	knight.animation_player.play("run") # play animation 
	current_acceleration = acceleration #get current acceleration
	target_speed = move_speed #update the target speed to base speed
	if Input.is_action_pressed( "sprint" ): #update the target speed to running speed
		target_speed = sprint_speed
	pass


func exit() -> void:
	knight.animation_player.speed_scale = 1 #reset animation speed
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if input_enabled:
		if _event.is_action_pressed("sprint"): #update the target speed to running speed
			target_speed = sprint_speed
		elif _event.is_action_released("sprint"): #update the target speed to base speed
			target_speed = move_speed
		elif _event.is_action_pressed("jump"): #allow transition to jump if pressed
			return jump
		elif _event.is_action_pressed("attack"): #allow transition to attack if pressed
			return attack
		elif _event.is_action_pressed("shield"):
			return shield
	return null


func process( _delta : float ) -> KnightState:
	return null


func physics_process( _delta : float ) -> KnightState:
	if not knight.is_on_floor(): # if we arent on the floor we are falling
		return fall
	
	if input_enabled:
		if direction.x == 0: #if the player isnt holding a direction on any axis return to idle
			return idle
		elif direction.y > 0: #pressing the down key 
			return crouch
		elif sign( direction.x ) == sign( knight.velocity.x ) or knight.velocity.x == 0:#if we are pushing the same direction we are running
			current_acceleration = acceleration #update current acceleration
			knight.animation_player.play("run") #play animation
			knight.animation_player.speed_scale = abs(knight.velocity.x) / move_speed #update the animation speed of running to look faster using absolute value of velocity divided by move speed
		else: #otherwise we are going the opposite direction so we need to turn around or "skid"
			current_acceleration = skid_acceleration #set acceleration to skid acceleration
			knight.animation_player.play("skid")
		
		if direction.x != current_direction:#if our direction is not the current direction reset the current direction and update it
			current_direction = direction.x
			knight.update_direction( current_direction )
		
		
		knight.update_velocity( direction.x * target_speed, current_acceleration) #update velocity with our direction, move speed and delta using current_acceleration
	return null
