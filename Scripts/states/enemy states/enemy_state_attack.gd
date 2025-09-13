class_name EnemyStateAttack extends EnemyState

@export var vision_area : VisionArea #enemy vision
@export var state_aggro_duration : float = 0.5 #duration of aggro

var deceleration : float = 10.0
var _timer : float = 0.0
var _can_see_player : bool = false


func init() -> void:
	if vision_area: #if a vision area is connected connect player area entered and exited function
		vision_area.player_enetered.connect( _on_player_entered )
		vision_area.player_exited.connect( _on_player_exited )
	pass


func enter() -> void:
	print("enter attack")
	_can_see_player = true #enemy sees the player
	_timer = state_aggro_duration #timer is equal to our aggro duration
	enemy.update_animation("attack") #play attack animation
	
	enemy.animation_player.animation_finished.connect( _on_attack_finished ) #connect to attack finished function after 1st attack
	pass


func exit() -> void:
	print("exit attack")
	_can_see_player = false #enemy cant see player
	enemy.animation_player.animation_finished.disconnect( _on_attack_finished ) #disconnect signal
	pass


func process( _delta : float ) -> EnemyState:
	if _can_see_player == false: #if we cant see the enemy start timer
		_timer -= _delta
		
		if _timer <= 0: #once out go to idle
			return idle
	else:
		_timer = state_aggro_duration 
	return null


func physics_process( _delta : float ) -> EnemyState:
	enemy.update_velocity( enemy.velocity.x , deceleration )
	return null


func _on_player_entered() -> void:
	_can_see_player = true #enemy can see the player
	if(
		state_machine.current_state is EnemyStateHurt #cant attack during hurt or death states
		or state_machine.current_state is EnemyStateDeath
	):
		return
	state_machine.change_state( self ) #change state to attack
	pass

func _on_player_exited() -> void:
	_can_see_player = false #cant see player anymore
	pass


func _on_attack_finished( _anim : String ) -> void:
	if GlobalPlayerManager.knight.hp <= 0: # if player has no hp go to wander
		state_machine.change_state(patrol)
		return

	if _can_see_player != false: #if enemy is still inside vision after an attack, attack again
		enemy.update_animation("attack")
	pass
