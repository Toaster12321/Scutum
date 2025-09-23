class_name EnemyStateIdle extends EnemyState

@export var state_duration_min : float = 0.5 #how long the state will last for
@export var state_duration_max : float = 1.5

var _timer : float = 0.0

func init() -> void:
	pass


func enter() -> void: 
	enemy.animation_player.play("idle") #play idle animation 
	_timer = randf_range( state_duration_min, state_duration_max ) #set timer to a random amount between desired time
	enemy.velocity = Vector2.ZERO #stop enemy
	pass


func exit() -> void:
	pass


func process( _delta : float ) -> EnemyState:
	_timer -= _delta #start state timer
	if _timer <= 0:
		return patrol #start wandering when over
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null
