@tool #used in editor only
class_name PatrolLocation extends Node2D

signal transform_changed

@export var node_number_text : String = "": #node number, uses setter function to update anywhere
	set( v ):
		node_number_text = v
		_update_label()
@export var wait_time : float = 0.0: #variable wait time, uses setter function to update anywhere
	set( v ):
		wait_time = v
		_update_wait_time_label()

var target_position : Vector2 = Vector2.ZERO


func _enter_tree() -> void: #when the node enters the scene tree
	set_notify_transform(true) #enables notifs for when the transform of this node changes


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED: #if the transform has changed emit the signal
		transform_changed.emit()


func _ready() -> void:
	target_position = global_position #set position
	_update_wait_time_label() #set wait time label
	_update_label()
	
	if Engine.is_editor_hint(): #dont play this script in game
		return
	
	$Sprite2D.queue_free() #hide the sprite for this node in game


func _update_label() -> void:
	if Engine.is_editor_hint():
		$Sprite2D/Label.text = node_number_text #update number of node (starts at 0)
	pass


func _update_wait_time_label() -> void:
	if Engine.is_editor_hint():
		$Sprite2D/Label2.text = "wait:" + str( snappedf( wait_time, 0.1 ) ) + "s" #set label text to the wait time, snapped f to make sure wait time is to the tenth decimal palce
