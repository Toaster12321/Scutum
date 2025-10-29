class_name EnemyStatePatrol extends EnemyState

@export var wander_speed : float = 30.0 

var _direction : Vector2
var patrol_locations : Array[ PatrolLocation ]
var current_location_index : int = 0
var target : PatrolLocation
var has_started : bool = false
var last_phase : String = ""
var spawn_position : Vector2
var patrol_walk : bool = true

@onready var timer: Timer = $Timer


func init() -> void:
	pass


func enter() -> void:
	print("enetered patrol")
	spawn_position = enemy.global_position
	gather_patrol_locations() #gather nodes
	if patrol_locations.size() < 2:
		patrol_walk = false
		return
		
	if Engine.is_editor_hint():
		child_entered_tree.connect( gather_patrol_locations ) #gather patrol locations when a new node enters the tree
		child_order_changed.connect( gather_patrol_locations )  #gather patrol locations when a new node changes in the tree
		return
	
	if patrol_locations.size() == 0: #if array is empty disable node
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	patrol_walk = true
	
	if current_location_index >= patrol_locations.size():
		current_location_index = 0 #reset if neccessary

	target = patrol_locations[ current_location_index ] #target location is the first node
	
	if has_started == true:
		if timer.time_left == 0:
			walking()
		return
	
	has_started = true
	walking()
	pass


func exit() -> void:
	print("exited patrol")
	patrol_walk = false #reset bools
	has_started = false
	timer.stop()
	pass


func process( _delta : float ) -> EnemyState:
	if patrol_walk == true:
		if enemy.global_position.distance_to( target.target_position ) < 10: #if the enemy is within 4 pixels of the target position, idle
			idling()
		if enemy.global_position.distance_to( spawn_position ) > enemy.patrol_range:#if the enemy is out of range, change state to wander
			return wander
	else:
		return wander
	return null


func physics_process( _delta : float ) -> EnemyState:
	return null


func gather_patrol_locations( _n : Node = null ) -> void:
	patrol_locations = [] #set array to empty
	for c in enemy.get_children(): # append each location in the array
		if c is PatrolLocation:
			patrol_locations.append( c )
	pass


func idling() -> void:
	enemy.velocity = Vector2.ZERO #stop moving
	enemy.animation_player.play("idle") #play idle animation
	
	var wait_time : float = target.wait_time
	
	current_location_index += 1 #add 1 to the location index
	if current_location_index >= patrol_locations.size(): #wrap the array if neccessary
		current_location_index = 0
	
	target = patrol_locations[ current_location_index ] #change target to new index
	
	if wait_time > 0: #if we have time
		timer.start( wait_time ) #start idle timer till timeout
		await timer.timeout
	
	walking() #go to walking
	pass


func walking() -> void:
	_direction = global_position.direction_to( target.target_position ) #our direction is towards the location node
	enemy.direction = _direction 
	enemy.velocity = _direction * wander_speed #set velocity
	
	enemy.set_direction( _direction ) #set left or right direction
	enemy.animation_player.play("walk")
	pass
