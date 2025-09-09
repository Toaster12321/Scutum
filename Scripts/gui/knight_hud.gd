extends CanvasLayer

var shields : Array[ ShieldGUI ] = [] #array of our shields (life)

func _ready() -> void:
	for child in $Control/HFlowContainer.get_children(): #for each shield in the container append them to array 
		if child is ShieldGUI:
			shields.append( child )
			print("Shields size:", shields.size())
			child.visible = false #turn visibility off
	
	pass


func update_hp( _hp : int, _max_hp : int ) -> void:
	update_max_hp( _max_hp ) #update max hp to make sure there is enough life available
	for i in shields.size(): #from 0 to to number of shields
		update_shield( i, _hp ) #update life
		pass
	pass


func update_shield( _index : int, _hp : int ) -> void:
	var _value : int = clampi( _hp - _index * 2, 0 , 2) #clamp value to not go over max hp, current hp - index from max hp * 2 gets value of 0,1,2
	shields[ _index ].value = _value #set the shield value
	pass



func update_max_hp( _max_hp : int ) -> void:
	var _shield_count : int = roundi( _max_hp * 0.5 ) #get the shield count of max hp * 1/2 because frames 0 to 2 means 3 frames
	for i in shields.size(): #for every shield in the array
		if i < _shield_count: #if i is greater than the shield count turn shields on
			shields[i].visible = true
		else:
			shields[i].visible = false
	pass
