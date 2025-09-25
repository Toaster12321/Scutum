class_name EnemyStateAttack extends EnemyState

@export var vision_area : VisionArea #enemy vision
@export var state_aggro_duration : float = 0.5 #duration of aggro

var deceleration : float = 30.0
var _timer : float = 0.0
var _can_see_player : bool = false
var next_state : EnemyState
var chance : int


func init() -> void:
	if vision_area: #if a vision area is connected connect player area entered and exited function
		vision_area.player_enetered.connect( _on_player_entered )
		vision_area.player_exited.connect( _on_player_exited )
	pass


func enter() -> void:
	_can_see_player = true #enemy sees the player
	_timer = state_aggro_duration #timer is equal to our aggro duration
	enemy.update_animation("attack") #play attack animation
	
	if not enemy.animation_player.animation_finished.is_connected( _on_attack_finished ):#make sure it isnt connected
		enemy.animation_player.animation_finished.connect( _on_attack_finished ) #connect to attack finished function after 1st attack
	pass


func exit() -> void:
	_can_see_player = false #enemy cant see player
	enemy.animation_player.animation_finished.disconnect( _on_attack_finished ) #disconnect signal
	pass


func process( _delta : float ) -> EnemyState:
	chance = randi_range(0,1) #make chance a 50/50
	if _can_see_player == false: #if we cant see the enemy start timer
		_timer -= _delta
		
		if _timer <= 0: #once out go to idle
			return idle
	else:
		_timer = state_aggro_duration 
	return null


func physics_process( _delta : float ) -> EnemyState:
	if not enemy.is_on_floor():
		return wander
		
	enemy.update_velocity( 0 , deceleration )
	return null


func _on_player_entered() -> void:
	_can_see_player = true #enemy can see the player
	if(
		state_machine.current_state is EnemyStateHurt #cant attack during hurt or death states
		or state_machine.current_state is EnemyStateDeath
	):
		return
	if chance == 0: #50/50 to attack or cast
		next_state = self
	else:
		if casting:
			next_state = casting
		else:
			next_state = self
	state_machine.change_state( next_state ) #change state to attack or cast
	pass

func _on_player_exited() -> void:
	_can_see_player = false #cant see player anymore
	pass


func _on_attack_finished( _anim : String ) -> void:
	enemy.audio.stop()
	
	if GlobalPlayerManager.knight.hp <= 0: # if player has no hp go to wander
		state_machine.change_state(patrol)
		return

	if _can_see_player != false: #if enemy is still inside vision after an attack, attack again
		if chance == 0:
			if casting:
				state_machine.change_state(casting)
			else:
				print("casting false")
				enemy.update_animation("attack")
		else:
			enemy.update_animation("attack")
	else:
		state_machine.change_state(idle)
	pass
