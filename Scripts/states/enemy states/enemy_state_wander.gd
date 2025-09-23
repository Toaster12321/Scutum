class_name EnemyStateWander extends EnemyState

@export var wander_speed : float = 30.0
@export var state_animation_duration : float = 0.5
@export var state_cycles_min : int = 1
@export var state_cycles_max : int = 3

var _timer : float = 0.0
var _direction : Array[ Vector2 ]

func init() -> void:
	pass


func enter() -> void:
	enemy.animation_player.play("walk")
	_timer = randi_range( state_cycles_min, state_cycles_max) * state_animation_duration
	_direction = [Vector2.RIGHT, Vector2.LEFT]
	var rand = randi_range(0,1)
	var rand_direction = _direction[ rand ]
	enemy.velocity = rand_direction * wander_speed
	enemy.set_direction( rand_direction )
	pass


func exit() -> void:
	pass


func process( _delta : float ) -> EnemyState:
	_timer -= _delta
	if _timer <= 0:
		return idle
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null
