extends Node


signal TileMapBoundsChanged( bounds : Array[ Vector2 ] )
signal level_load_started
signal level_loaded

var current_tilemap_bounds : Array[ Vector2 ]
var target_transition : String
var position_offset : Vector2

func _ready() -> void:
	await get_tree().process_frame #wait a frame then emit that the level has loaded
	level_loaded.emit()


func ChangeTileMapBounds( bounds : Array [Vector2] ) -> void: 
	current_tilemap_bounds = bounds #get new tile map boundraries
	TileMapBoundsChanged.emit( bounds ) #emit signal with bounds passed
	pass


func load_new_level(
	level_path : String, 
	_target_transition : String,
	_position_offset : Vector2
) -> void:
	get_tree().paused = true #pause scene functions
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.fade_out() #play fade out animation
	
	level_load_started.emit() #emit level has started to load
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file( level_path ) #change scene to passed in level
	
	await SceneTransition.fade_in() #play fade in animation
	
	get_tree().paused = false #turn back on scene functions
	
	await get_tree().process_frame
	
	
	#ONLY FOR DEBUG, MESSES UP SAVE/LOAD FUNCTIONALITY
	#var level_root = get_tree().current_scene #get current scene
	#if level_root: #if it has a spawn location in scene set spawn position to that location
		#var spawn_location = level_root.get_node_or_null("PlayerSpawn")
		#if spawn_location:
			#GlobalPlayerManager.set_player_position(spawn_location.global_position)
	
	level_loaded.emit() #emit level is done loading
	
	pass
