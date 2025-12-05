class_name KnightStateShield extends KnightState

@export var shielding_speed : float = 40.0 #movement for walking while shielding
@export var deceleration : float = 5.0

@onready var hitbox: Hitbox = $"../../Hitbox"
@onready var shieldbox: Shieldbox = $"../../ShieldHitbox"

var hurtbox : Hurtbox
var _next_state : KnightState = null
var shielding : bool =  false
var _blocked : bool = false


func init() -> void:
	knight.damage_blocked.connect( _damage_blocked ) #connect damage blocked signal from knight class
	pass


func enter() -> void:
	shielding = true # we are shielding
	
	if direction.x == 0: #if we arent moving play idle shield animation otherwise play walking animation
		knight.animation_player.play("shield")
	else:
		knight.animation_player.play("shield_walk_forward")
	pass


func exit() -> void:
	_blocked = false #not blocking anymore
	shielding = false #we arent shielding
	_next_state = null #reset next state
	pass 


func handle_input( _event : InputEvent ) -> KnightState:
	if _event.is_action_pressed("jump"): #transition to jump state when button is pressed
		return jump
	elif _event.is_action_pressed("attack"): #transition to attack state when button is pressed
		if knight.attack_locked:  #prevent attacking again if cooldown is still active
			return null
		return attack
	return null


func process( _delta : float ) -> KnightState:
	if _blocked == true: #if we did block an attack return deflect
		_blocked = false
		return _next_state
		
	shielding = Input.is_action_pressed("shield") #keep track if we are shielding every frame 
	if shielding:#decrease stamina while shielding
		KnightHud.decrease_stamina(0.15)
	elif shielding == false: #if we stop shielding go to idle and increase stam back
		KnightHud.increase_stamina(0.5)
		return idle
	
	knight.update_velocity( direction.x * shielding_speed, deceleration ) #slow player down to shield walk speed
	
	if KnightHud.stamina_progress_bar.value <= 0.1: #cant shield if no stamina
		KnightHud.increase_stamina(0.5)#increase stamina and switch to idle
		return idle 
	
	if direction.x == 0: #play shield idle if not moving
		knight.animation_player.play("shield")
	else: #other wise play forward animation if our directions match each other
		if sign(direction.x) == sign(knight.current_direction):
			knight.animation_player.play("shield_walk_forward")
		else:
			knight.animation_player.play("shield_walk_back")
	return null


func physics_process( _delta : float ) -> KnightState:
	if shielding == false: #if we arent shielding
		if knight.velocity.x != 0: #if the player is holding any direction in the x axis we are running 
			return run
		elif direction.y > 0: #pressing the down key 
			return crouch
		elif not knight.is_on_floor(): # if we are in the air go to fall state
			return fall
	return null


func _damage_blocked( _hurtbox : Hurtbox ) -> void:
	hurtbox = _hurtbox #get passed hurtbox
	if hurtbox.hurtbox_type == Hurtbox.HurtboxType.BODY: #if we are hitting the body hitbox dont deflect
		hit.hurtbox = hurtbox
		state_machine.change_state(hit)
	
	_blocked = true #we blocked the attack
	if state_machine.current_state != deflect: #prevent multiple animations
		_next_state = deflect #deflect
	pass
