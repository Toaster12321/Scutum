class_name EnemyStateHurt extends EnemyState

@export var knockback_speed : float = 200.0 #how fast enemy gets pushed back
@export var decelerate_speed : float = 10.0 #velocity decrease speed
@export var hurt_duration : float = 0.4 #average time of hurt animation
@export var _can_be_knockbacked : bool = true
@export var effect_animations : AnimationPlayer

var _damage_position : Vector2
var _direction : Vector2
var _hurt_timer : float = 0.0

func init() -> void: 
	enemy.enemy_damaged.connect( _on_enemy_damaged ) # connect enemy damaged signal
	pass


func enter() -> void:
	#print("enetered hurt")
	_hurt_timer = 0.0 #reset hurt timer
	enemy.invulnerable = true #make enemy invulnerable to multiple hits during animation
	_direction = enemy.global_position.direction_to( GlobalPlayerManager.knight.global_position ) #get direction based on global position of damage position
	enemy.set_direction( _direction )
	
	if _can_be_knockbacked:
		enemy.velocity = _direction * -knockback_speed #push enemy backward
	
	enemy.animation_player.stop() #stop previous animation
	enemy.animation_player.play("hurt") #play hurt animation 
	
	pass


func exit() -> void: 
	#print("exit hurt")
	enemy.invulnerable = false #no longer invulnerable 
	pass


func process( _delta : float ) -> EnemyState:
	_hurt_timer += _delta #start timer
	if _hurt_timer >= hurt_duration:  #return the attack state when animation is over
		return attack #retaliate
	enemy.update_velocity( 0, decelerate_speed ) #deceleration speed
	return null


func physics_process( _delta : float ) -> EnemyState:
	if not enemy.is_on_floor() and _hurt_timer >= hurt_duration:
		return wander
	return null


func _on_enemy_damaged( hurtbox : Hurtbox ) -> void: #when enemy damaged signal is connected
	_damage_position = hurtbox.global_position #get position vector of the hurtbox
	match enemy.enemy_type: #cases where we dont apply knockback or hurt state enter
		
		enemy.EnemyType.WARRIOR:
			var anim : String = ""
			if enemy.animation_player:
				anim = enemy.animation_player.current_animation
			if anim != "" and anim.begins_with("attack"): #warrior attacking animation
				enemy.invulnerable = true #make invulnerable
				effect_animations.play("flash")  #play damage flash
				await get_tree().create_timer(0.4).timeout #wait 0.4 seconds till can be damaged again
				enemy.invulnerable = false
				return
		
		enemy.EnemyType.DEATHBRINGER:
			var anim : String = ""
			if enemy.animation_player:
				anim = enemy.animation_player.current_animation
			if anim != "" and anim.begins_with("casting"): #deathbringer casting animation
				enemy.invulnerable = true
				enemy.effect_animations.play("flash")
				await get_tree().create_timer(0.4).timeout
				enemy.invulnerable = false
				return
		
		
	if state_machine.current_state != self:
		state_machine.change_state( self ) # change state to hurt
	pass
