class_name EnemyStateMachine extends Node2D

var states : Array[ EnemyState ] #array of states
var current_state : EnemyState : #returns first element in the state array
	get : return states.front()
var previous_state : EnemyState : #returns second(previous) element in the state array
	get : return states[1]


var enemy : Enemy#knight instance


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED #disable this node on default
	pass


func _process( _delta : float) -> void:
	var new_state = current_state.process( _delta ) #obtaining new state information then change state if neccessary
	change_state( new_state )
	pass


func _physics_process( _delta : float) -> void:
	var new_state = current_state.physics_process( _delta )  #obtaining new state information then change state if neccessary
	change_state( new_state )
	pass


func change_state( _new_state : EnemyState ) -> void:
	if _new_state == null or enemy.enemy_dead == true: # if the new state doesn't exist or is the same as the current do nothing
		return
	elif _new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	states.push_front( _new_state ) # add new state to the front of array
	current_state.enter() #call enter function of new state
	states.resize( 3 ) #keeps track of 3 states at a time by shrinking size
	pass


func init( _enemy : Enemy ) -> void:
	enemy = _enemy #get enemy instance
	states = [] #clear states array
	
	for c in get_children(): #check children of state machine, if they are a state append them to array
		if c is EnemyState:
			states.append(c)
			c.enemy = enemy
			c.state_machine = self #assign enemy and statemachine in state template called enemy state
	
	if states.size() == 0:
		return
	
	for state in states:
		state.init() #initialize states
	
	change_state( current_state ) #change state to first in array
	current_state.enter() #call enter function of current state
	process_mode = Node.PROCESS_MODE_INHERIT #enable state machine 
	
	pass
