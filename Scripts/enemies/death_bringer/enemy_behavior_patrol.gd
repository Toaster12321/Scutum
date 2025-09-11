@tool
class_name EnemyBehaviorPatrol extends EnemyBehavior

const COLORS = [ Color(1,0,0), Color(1,1,0), Color(0,1,0), Color(0,1,1), Color(0,0,1), Color(1,0,1) ] #colors for editor patrol locations

@export var walk_speed : float = 30.0

var patrol_locations : Array[ PatrolLocation ]
var current_location_index : int = 0
var target : PatrolLocation

var has_started : bool = false
var last_phase : String = ""
var direction : Vector2

@onready var timer: Timer = $Timer

func _ready() -> void:
	gather_patrol_locations()
	pass


func gather_patrol_locations( _n : Node = null ) -> void:
	patrol_locations = [] #set array to empty
	for c in get_children(): # append each location in the array
		if c is PatrolLocation:
			patrol_locations.append( c )
	
	if Engine.is_editor_hint():
		if patrol_locations.size() > 0:
			for i in patrol_locations.size(): #if we have any locations loop through them
				var _p = patrol_locations[ i ] as PatrolLocation #set _p to each location for every iteration
			
				if not _p.transform_changed.is_connected( gather_patrol_locations ): #if transform change isnt connected, connect it
					_p.transform_changed.connect( gather_patrol_locations )
				
				_p.update_label( str(i) ) #set label to iteration number
				_p.modulate = _get_color_by_index( i ) # set colors
				
				var _next : PatrolLocation
				if i < patrol_locations.size() - 1: #if we have locations
					_next = patrol_locations[ i + 1 ] #next location is current index + 1
				else:
					_next = patrol_locations[ 0 ] #otherwise next index is the beginning index
				_p.update_line( _next.position ) #draw line to each position of location nodes
	
	pass


func start() -> void:
	if enemy.do_behavior == false or patrol_locations.size() < 2:
		return
	
	
	if has_started == true:
		if timer.time_left == 0:
			enemy.enemy_state_machine.change_state(idle)


func _get_color_by_index( i : int ) -> Color:
	var color_count : int = COLORS.size() #get size of color list
	while i > color_count -1: #while there are colors available
		i -= color_count #go through each color in order
	return COLORS[ i ] #return color based on current index
