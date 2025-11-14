class_name KnightStateMachine extends Node2D


var states : Array[ KnightState ] #array of states
var current_state : KnightState : #returns first element in the state array
	get : return states.front()
var previous_state : KnightState : #returns second(previous) element in the state array
	get : return states[1]
var input_enabled : bool = true


var knight : Knight#knight instance


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED #disable this node on default
	pass


func _process( _delta : float) -> void:
	#gets direction of player
	if input_enabled:
		current_state.direction = Vector2(
			sign( Input.get_axis( "move_left","move_right" ) ), #gets input axis, left for negative, right for pos, sign makes value range from -1 to 1 without half values
			sign( Input.get_axis( "jump", "crouch" ) )#gets input axis, jump(up) for negative, down for pos
			)
	
	var new_state = current_state.process( _delta ) #obtaining new state information then change state if neccessary
	change_state( new_state )
	pass


func _physics_process( _delta : float) -> void:
	var new_state = current_state.physics_process( _delta )  #obtaining new state information then change state if neccessary
	change_state( new_state )
	pass


func _unhandled_input( _event : InputEvent) -> void:
	var new_state = current_state.handle_input( _event )  #obtaining new state information then change state if neccessary
	change_state( new_state )
	pass


func change_state( _new_state : KnightState ) -> void:
	if _new_state == null: # if the new state doesn't exist or is the same as the current do nothing
		return
	elif _new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	states.push_front( _new_state ) # add new state to the front of array
	current_state.enter() #call enter function of new state
	states.resize( 3 ) #keeps track of 3 states at a time by shrinking size
	pass


func init( _knight : Knight ) -> void:
	knight = _knight #get knight instance
	states = [] #clear states array
	
	for c in get_children(): #check children of state machine, if they are a state append them to array
		if c is KnightState:
			states.append(c)
	
	if states.size() == 0:
		return
	
	current_state.knight = knight #assign knight and statemachine in state template called knight state
	current_state.state_machine = self
	
	for state in states:
		state.init() #initialize states
	
	change_state( current_state ) #change state to first in array
	current_state.enter()
	process_mode = Node.PROCESS_MODE_INHERIT #enable state machine 
	
	pass
