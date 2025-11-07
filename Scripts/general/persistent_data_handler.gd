class_name PersistentDataHandler extends Node

signal data_loaded
var value : bool = false

func _ready() -> void:
	get_value()
	pass


func set_value() -> void:  #adds persistent value path
	GlobalSaveManager.add_persistence_value( _get_name() )


func get_value() -> void: #gets persistent value path and returns true or false if its in the persistence array
	value = GlobalSaveManager.check_persistent_value( _get_name() )
	data_loaded.emit()


func remove_value() -> void:  #removes persistent value path
	GlobalSaveManager.remove_persistence_value( _get_name() )

func _get_name() -> String:
	#gets file path, looks like "res://levels/area01.tscn/tresurechest/PersistentDataHandler"
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
