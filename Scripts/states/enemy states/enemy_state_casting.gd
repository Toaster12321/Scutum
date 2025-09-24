class_name EnemyStateCasting extends EnemyState

const SPELL_SCENE : PackedScene = preload("res://Scenes/enemies/spell.tscn")

var positions : Array[ Node2D ] #array for spell positions
var deceleration : float = 100.0

func init() -> void:
	positions = [] #clear array
	for c in $"../../PositionTargets".get_children(): #append positions to array
		positions.append( c )
	print(positions)
	$"../../PositionTargets".visible = false #turn off indicator
	pass


func enter() -> void:
	enemy.animation_player.play("casting") #play animation and cast spell
	cast_spell() 
	enemy.animation_player.animation_finished.connect( _on_anim_finished )
	pass


func exit() -> void:
	enemy.animation_player.animation_finished.disconnect( _on_anim_finished )
	pass


func process( _delta : float ) -> EnemyState:
	enemy.update_velocity( 0 , deceleration ) #stop enemy
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null


func cast_spell() -> void:
	if positions.size() == 0: 
		print("no positions found")
		
	var spell : Node2D = SPELL_SCENE.instantiate() #instatiate 2 spells
	var spell2 : Node2D = SPELL_SCENE.instantiate()
	spell.global_position = positions[0].global_position #set their position to the indicator set in editor
	spell2.global_position = positions[1].global_position
	
	enemy.get_parent().add_child.call_deferred( spell ) #add spells as a child to the enemy
	enemy.get_parent().add_child.call_deferred( spell2 )


func _on_anim_finished( _anim : String) -> void:
	enemy.enemy_state_machine.change_state(attack) #on finished go back to attacking
	pass
