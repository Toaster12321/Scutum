class_name EnemyBehavior extends Node2D

var enemy : Enemy

func _ready() -> void:
	var p = get_parent()
	if p is Enemy:
		enemy = p as Enemy
		enemy.do_behavior_enabled.connect( start )

func start() -> void:
	pass
