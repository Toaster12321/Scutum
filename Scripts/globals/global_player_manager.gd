extends Node

const KNIGHT = preload("res://Scenes/knight/knight_player.tscn") #preload for knight scene

var knight : Knight #create instance for knight
var knight_spawned : bool = false

func _ready() -> void:
	add_player_instance() #add knight on startup
	await get_tree().create_timer(0.2).timeout #after 0.2 seconds knight has spawned
	knight_spawned = true 
	pass


func add_player_instance() -> void:
	knight = KNIGHT.instantiate() #instantiate knight scene and add it
	add_child( knight ) 
	pass


func set_player_position( _new_pos : Vector2 ) -> void: #function that sets the knight at a set of coords
	knight.global_position = _new_pos
	pass


func set_as_parent( _p : Node2D ) -> void:
	if knight.get_parent(): #if we have an instance of the knight set it as the parent node
		knight.get_parent().remove_child( knight )
	_p.add_child( knight )


func unparent_player( _p : Node2D ) -> void: 
	_p.remove_child( knight ) #unparent knight
