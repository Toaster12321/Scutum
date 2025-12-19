class_name Knight extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var idle: KnightStateIdle = %Idle
@onready var run: KnightStateRun = %Run
@onready var jump: KnightStateJump = %Jump
@onready var fall: KnightStateFall = %Fall
@onready var crouch: KnightStateCrouch = %Crouch
@onready var deflect: KnightStateDeflect = %Deflect
@onready var knight_state_machine: KnightStateMachine = $KnightStateMachine
@onready var shield: KnightStateShield = %Shield
@onready var attack: KnightStateAttack = %Attack
@onready var death: KnightStateDeath = %Death
@onready var hit: KnightStateHit = %Hit
@onready var sprites: Node2D = $Sprites
@onready var hitbox: Hitbox = $Hitbox
@onready var shieldbox: Shieldbox = $ShieldHitbox
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer


var gravity : float = 980 #9.81m/s gravity speed
var gravity_multiplier : float = 1
var current_direction : float = 1
var default_cam_position_y : float
var default_cam_position_x : float
var default_cam_position : Vector2 = Vector2(default_cam_position_x,default_cam_position_y)
var facing_direction : float = 1
var drop_start_y : float = 0.0

signal player_damaged( hurtbox : Hurtbox )
signal damage_blocked( hurtbox : Hurtbox )

var invulnerable = false
var attack_locked : bool = false
var hp : int = 6
var max_hp : int = 6

func _ready() -> void:
	#if !GlobalSaveManager.has_seen_intro(): #check to see if we have seen the intro cutscene yet
		#knight_state_machine.input_enabled = false
		
	GlobalPlayerManager.knight = self #initialize player manager reference
	knight_state_machine.init(self) #inistialize state machine to player
	default_cam_position_x = camera_2d.position.x
	default_cam_position_y = camera_2d.position.y #get default camera y placement
	hitbox.damaged.connect( _take_damage ) #connect take damage function if hitbox has been entered
	shieldbox.deflected.connect( _block_damage ) #connect deflected function if shieldbox has been entered
	update_hp(99) #restore player to full hp
	KnightHud.set_stamina(100.0)#set stamina to full
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_finished) #function called after attack cooldown is over
	pass


func _physics_process(delta: float) -> void:
	if is_on_floor() == false: #if not on floor
		velocity.y += gravity * delta * gravity_multiplier #applying gravity in the y axis
	move_and_slide() # allows movement


func _process(_delta: float) -> void:
	pass


func update_velocity( _velocity : float, _acceleration : float ) -> void:
	velocity.x = move_toward( velocity.x, _velocity, _acceleration ) #updates velocity in the x axis from base velocity to max velocity passed in at a delta value of acceleration
	pass


func play_audio( _audio : AudioStream ) -> void: #function to play audio streams
	if audio == null:
		return
	
	audio.stream = _audio
	audio.play()
	pass


func update_direction( direction : float ) -> void: #when we change from left to right or vice versa update animation name to respective direction
	if direction != 0: #if we arent not standing still set the current direction to passed in direction
		current_direction = direction
	
	if current_direction < 0: #if our direction is -1 we are going left otherwise right
		sprites.scale.x = -1 #flip left
		facing_direction = -1
	else:
		sprites.scale.x = 1 #flip right
		facing_direction = 1
	pass


func update_animation( state : String ) -> void: #function that takes a state and updates its animation if it needs multiple directions
	animation_player.play(state + "_" + anim_direction())


func anim_direction() -> String: #returns a left or right based on the current direction of the player
	if current_direction < 0:
		return "left"
	else:
		return "right"


func _take_damage( hurtbox : Hurtbox ) -> void: #take damage function for player
	if invulnerable == true: #do nothing if we have been hit already
		return 
	 
	if hp > 0: #if we have hp decrease it
		GlobalSignalManager.on_camera_feedback_requested.emit(20, .2, 300)
		update_hp( -hurtbox.damage )
		player_damaged.emit( hurtbox ) #trigger the player damaged signal with hurtbox passed in
	pass


func _block_damage( hurtbox : Hurtbox ) -> void:
	GlobalSignalManager.on_camera_feedback_requested.emit(5, .05, 50)
	damage_blocked.emit( hurtbox ) # trigger the damage blocked signal passing in the hurtbox
	pass


func update_hp( _delta : int ) -> void: #increases or decreases knights hp
	hp = clampi( hp + _delta, 0, max_hp ) #clamp to make sure hp stays between 0 and max
	KnightHud.update_hp( hp , max_hp ) #send hp and max hp to our player hud for life bar
	pass


func make_invulnerable( _duration : float ) -> void: #make knight invulnerable shortly
	invulnerable = true 
	hitbox.monitoring = false # turn off hitbox for a duration
	
	await get_tree().create_timer( _duration ).timeout #after duration ends we can be hit again
	invulnerable = false
	hitbox.monitoring = true
	pass


func revive_player() -> void:
	update_hp( 99 )
	knight_state_machine.change_state( idle )


func _on_attack_cooldown_finished() -> void:
	attack_locked = false #allow attacks again


func lock_attack() -> void:
	attack_locked = true #set attacks locked and start cooldown
	attack_cooldown_timer.start()


func set_platform_collision( enabled : bool ) -> void:
	if enabled:
		set_collision_mask_value(6,true) # 6 is one way ground collision
	else:
		set_collision_mask_value(6,false)
