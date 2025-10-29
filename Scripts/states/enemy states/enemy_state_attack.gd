class_name EnemyStateAttack extends EnemyState

enum EnemyType {DEATHBRINGER, WOLF, BAT, WARRIOR}

@export var vision_area : VisionArea #enemy vision
@export var state_aggro_duration : float = 0.5 #duration of aggro
@export var assess_speed : float = 10.0
@export var enemy_type : EnemyType


var deceleration : float = 60.0
var _charge_deceleration : float = 50.0
var _aggro_timer : float = 0.0
var leap_strength : float = 150
var _can_see_player : bool = false
var _assess_player : bool = false
var next_state : EnemyState
var chance : int

@onready var _assess_timer: Timer = $Timer


func init() -> void:
	if vision_area: #if a vision area is connected connect player area entered and exited function
		vision_area.player_enetered.connect( _on_player_entered )
		vision_area.player_exited.connect( _on_player_exited )
	else:
		print("vision not assigned")
	pass


func enter() -> void:
	print("enetered attack")
	_can_see_player = true #enemy sees the player
	_aggro_timer = state_aggro_duration #timer is equal to our aggro duration
	if enemy_type == EnemyType.DEATHBRINGER:
		enemy.update_animation("attack") #play attack animation
		enemy.velocity = Vector2.ZERO
	elif enemy_type == EnemyType.WOLF:
		enemy.animation_player.play("charge")
	elif enemy_type == EnemyType.WARRIOR:
		enemy.update_animation("attack") #play attack animation
		enemy.velocity = Vector2.ZERO
	elif enemy_type == EnemyType.BAT:
		assess()
		await _assess_timer.timeout 
		enemy.update_animation("attack") #play attack animation
		enemy.velocity = Vector2(leap_strength * enemy.facing_direction, enemy.velocity.y) #update velocity to a leapping burst of speed
	
	if not enemy.animation_player.animation_finished.is_connected( _on_attack_animation_finished ):#make sure it isnt connected
		enemy.animation_player.animation_finished.connect( _on_attack_animation_finished ) #connect to attack finished function after 1st attack
	pass


func exit() -> void:
	print("exited attack")
	_can_see_player = false #enemy cant see player
	_assess_player = false
	_assess_timer.stop()
	if enemy.animation_player.animation_finished.is_connected( _on_attack_animation_finished ):#make sure it isnt connected
		enemy.animation_player.animation_finished.disconnect( _on_attack_animation_finished )
	pass


func process( _delta : float ) -> EnemyState:
	chance = randi_range(0,1) #make chance a 50/50
	if _can_see_player == true: #if we see the enemy start timer
		_aggro_timer = state_aggro_duration #reset timer
	else:
		_aggro_timer -= _delta
		
		if _aggro_timer <= 0: #once out go to idle
			_can_see_player = false
			return idle
	
	if _assess_player == true: #if the enemy is assessing its next move
		enemy.update_velocity(enemy.velocity.x,0) #slow down velocity
		
		if _assess_timer.time_left <=0: #if timer is out it is now attacking
			_assess_player = false
			return self
	
	if enemy.animation_player.current_animation == "charge": #dont move during charge animation
		enemy.velocity = Vector2.ZERO
	return null


func physics_process( _delta : float ) -> EnemyState:
	if not enemy.is_on_floor() and enemy_type != EnemyType.BAT:
		return wander
	return null


func _on_player_entered() -> void:
	print("player entered")
	if(
		state_machine.current_state is EnemyStateHurt #cant attack during hurt or death states
		or state_machine.current_state is EnemyStateDeath
	):
		return
	_can_see_player = true #enemy can see the player
	enemy.set_direction( enemy.global_position.direction_to(GlobalPlayerManager.knight.global_position) ) #face the player
	if chance == 0: #50/50 to attack or cast
		next_state = self
	else:
		if enemy.has_node("%Casting"):
			next_state = casting
		else:
			next_state = self
	state_machine.change_state( next_state ) #change state to attack or cast
	pass


func _on_player_exited() -> void:
	print("player exited")
	_can_see_player = false #cant see player anymore
	pass


func _on_attack_animation_finished( _anim : String ) -> void:
	enemy.audio.stop()
	if GlobalPlayerManager.knight.hp <= 0: # if player has no hp go to patrol
		state_machine.change_state(patrol)
		return
	
	if _can_see_player == false or _aggro_timer <= 0:#if we cant see the player and the aggro duration is out, patrol
		state_machine.change_state(patrol)
	
	match enemy_type:
		EnemyType.WOLF:
			if _anim =="charge": #if last animation was charge
				enemy.animation_player.stop() #stop last animation
				await get_tree().create_timer(0.1).timeout  
				enemy.update_animation("attack") #attack after short pause
				enemy.velocity = Vector2(leap_strength * enemy.facing_direction, enemy.velocity.y) #update velocity to a leapping burst of speed
			elif _anim == "attack_right" or _anim == "attack_left":
				enemy.update_velocity(enemy.velocity.x * 0.5 ,_charge_deceleration) #update velocity to slow down
				enemy.set_direction( enemy.global_position.direction_to(GlobalPlayerManager.knight.global_position) ) #face the player
				if _aggro_timer > 0 and _can_see_player != false: #if enemy is still inside vision after an attack, attack again
					enemy.update_velocity(enemy.velocity.x * 0.5 ,_charge_deceleration) #slow velocity
					enemy.animation_player.stop() #stop previous animation
					await get_tree().create_timer(0.3).timeout
					enemy.animation_player.play("charge") #charge again after a short pause
				else:
					state_machine.change_state(wander)#otherwise wander
		
		EnemyType.DEATHBRINGER:
			if _anim == "attack_right" or _anim == "attack_left":
				if  _aggro_timer > 0 and _can_see_player != false: #if enemy is still inside vision after an attack, attack again
					assess()
					await _assess_timer.timeout
					if chance == 0 and enemy.has_node("%Casting"):  #if the enemy has a casting state
						state_machine.change_state(casting)
					else:
						enemy.velocity = Vector2.ZERO
						enemy.update_animation("attack")
				else:
					state_machine.change_state(wander)#otherwise wander
			
		EnemyType.BAT:
			if _anim == "attack_right" or _anim == "attack_left":
				enemy.update_velocity(enemy.velocity.x, _charge_deceleration)
				enemy.set_direction( enemy.global_position.direction_to(GlobalPlayerManager.knight.global_position) )
				if _aggro_timer > 0 and _can_see_player != false: #if enemy is still inside vision after an attack, attack again
					assess()
					await _assess_timer.timeout
					enemy.update_animation("attack")
					enemy.velocity = Vector2(leap_strength * enemy.facing_direction, enemy.velocity.y) #update velocity to a leapping burst of speed
				else:
					state_machine.change_state(wander)#otherwise wander
			
		EnemyType.WARRIOR:
			if _anim == "attack_right" or _anim == "attack_left":
				if  _aggro_timer > 0 and _can_see_player != false: #if enemy is still inside vision after an attack, attack again
					chance = 1
					assess()
					await _assess_timer.timeout
					enemy.velocity = Vector2.ZERO
					enemy.update_animation("attack")
				else:
					state_machine.change_state(wander)#otherwise wander
	
	pass


func assess() -> void:
	if _can_see_player == true:#if we can see the player and have attacked already we are assessing
		_assess_player = true
		var rand_assess_time : float = randf_range(0.8,1.2)
		_assess_timer.start(rand_assess_time) #start timer
		if chance == 0:
			enemy.animation_player.play("walk_backwards") #walk backwards away from the player for 1s
			enemy.velocity.x = -enemy.facing_direction * assess_speed
		elif chance == 1:
			enemy.animation_player.play("walk") #walk forwards to the player for 1s
			enemy.velocity.x = enemy.facing_direction * assess_speed
	pass
