extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved

var current_save : Dictionary = { #save variables
	scene_path = "",
	knight = {
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0
	},
	persistence = []
}

func save_game() -> void:
	KnightHud.save_popup()
	update_player_data() #get player data
	update_scene_path() #get level scene path
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE) #writes a file to the save path called save.sav
	var save_json = JSON.stringify( current_save ) #converts current save to JSON format
	file.store_line( save_json ) #stores the save in the file
	game_saved.emit() #emit that the game has saved
	pass


func get_save_file() -> FileAccess:
	return FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ) #returns a read of the save file 


func load_game() -> void:
	var file := get_save_file() #gets the save file
	var json := JSON.new() #new json file var
	json.parse( file.get_line() ) #parses passed in JSON text
	var save_dict : Dictionary = json.get_data() as Dictionary #stores json data into a save dictionary
	current_save = save_dict #overwrite the current save with the save dictionary
	
	GlobalLevelManager.load_new_level( current_save.scene_path, "", Vector2.ZERO ) #loads the save's scene path
	
	await GlobalLevelManager.level_load_started
	
	GlobalPlayerManager.set_player_position( Vector2( current_save.knight.pos_x, current_save.knight.pos_y )) #set knight variables
	GlobalPlayerManager.set_health( current_save.knight.hp, current_save.knight.max_hp )
	
	await GlobalLevelManager.level_loaded
	
	if KnightHud.auto_save_animation_player.is_playing(): #prevent seeing popup again on load
		KnightHud.auto_save_animation_player.stop()
	
	game_loaded.emit()
	pass


func update_player_data() -> void: #set current save vars to knight's respective vars in manager
	var k : Knight = GlobalPlayerManager.knight 
	current_save.knight.hp = k.hp
	current_save.knight.max_hp = k.max_hp
	current_save.knight.pos_x = k.global_position.x
	current_save.knight.pos_y = k.global_position.y


func update_scene_path() -> void:
	var p : String = "" #path
	for c in get_tree().root.get_children(): #get children from the root scene
		if c is Level: #if its a level get the path to the level
			p = c.scene_file_path
	current_save.scene_path = p #set current save's scene file path


func add_persistence_value( value : String ) -> void:
	if check_persistent_value( value ) == false: #if the value doesnt have the passed in persistence
		current_save.persistence.append( value ) #append it


func remove_persistence_value( value : String ) -> void:
	var p = current_save.persistence as Array # get current save's persistence values 
	p.erase( value ) # remove the passed in value from the array


func check_persistent_value( value : String ) -> bool:
	var p = current_save.persistence as Array # get current save's persistence values 
	return p.has( value ) #if the passed in value is in the array -> return true


func has_seen_intro() -> bool:
	return check_persistent_value("seen_intro")


func mark_intro_seen() -> void:
	add_persistence_value("seen_intro")
