class_name EnemyState extends Node2D
#state template + references


var enemy : Enemy
var state_machine : EnemyStateMachine
var direction : Vector2

@onready var idle: EnemyStateIdle = %Idle
@onready var patrol: EnemyStatePatrol = %Patrol
@onready var wander: EnemyStateWander = %Wander
@onready var hurt: EnemyStateHurt = %Hurt
@onready var death: EnemyStateDeath = %Death
@onready var attack: EnemyStateAttack = %Attack
@onready var casting: EnemyStateCasting = get_node_or_null("%Casting") #node or null cause not all enemies can cast



func ready() -> void:
	pass


func init() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func process( _delta : float ) -> EnemyState:
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null
