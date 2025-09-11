class_name Enemy extends CharacterBody2D

signal direction_changed( new_direction : Vector2 )
signal enemy_damaged( hurt_box : Hurtbox )
signal enemy_destroyed( hurt_box : Hurtbox )

@export var hp : int = 5

var gravity : float = 980 #9.81m/s gravity speed
var gravity_multiplier : float = 1
var direction : Vector2 = Vector2.ZERO
var knight : Knight
var invulnerable : bool = false

const DIR_2 = [ Vector2.LEFT, Vector2.RIGHT ] #enemies two directions

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wander: EnemyStateWander = %Wander
@onready var hurt: EnemyStateHurt = %Hurt
@onready var death: EnemyStateDeath = %Death
@onready var attack: EnemyStateAttack = %Attack
@onready var enemy_state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var sprite: Node2D = $Sprite
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	enemy_state_machine.init( self ) #initialize state machine
	knight = GlobalPlayerManager.knight
	hitbox.damaged.connect( _take_damage ) #if enemy hitbox has been entered by a hurtbox connect damaged function
	pass


func _physics_process(delta: float) -> void:
	if is_on_floor() == false: #if not on floor
		velocity.y += gravity * delta * gravity_multiplier #applying gravity in the y axis
	move_and_slide() # allows movement
	pass


func set_direction( _new_direction : Vector2 ) -> void:
	if _new_direction != Vector2.ZERO: #if we arent idle set direction to passed in
		direction = _new_direction
	
		if direction.x < 0: #since sprite starts left side we flip logic
			sprite.scale.x = 1   #if we are facing left flip to right
		elif direction.x > 0: 
			sprite.scale.x = -1 #if we are facing right flip to left
	
	direction_changed.emit( direction ) #emit signal for direction changed


func _take_damage( hurtbox : Hurtbox ) -> void: #function called when damaged signal has been connected
	if invulnerable == true: #if we have already been hit we cant be hit agian
		return
	hp -= hurtbox.damage #decrease hp
	if hp > 0:
		enemy_damaged.emit( hurtbox ) #trigger signal to enemy damaged
	else:
		enemy_destroyed.emit( hurtbox ) #trigger signal to enemy destroyed


func update_animation( state : String ) -> void: #function that takes a state and updates its animation if it needs multiple directions
	animation_player.play(state + "_" + anim_direction())
	pass


func anim_direction() -> String: #returns a left or right based on the current direction of the player
	if direction.x < 0:
		return "left"
	else:
		return "right"
