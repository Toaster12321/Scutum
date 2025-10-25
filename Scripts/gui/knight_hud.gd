extends CanvasLayer

const level_1 : String = "res://Scenes/levels/level_1.tscn"
const title_screen : String = "res://Scenes/levels/title_screen.tscn"

@onready var game_over: Control = $Control/GameOver
@onready var try_again_button: Button = $Control/GameOver/HBoxContainer/TryAgainButton
@onready var title_button: Button = $Control/GameOver/HBoxContainer/TitleButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer

var shields : Array[ ShieldGUI ] = [] #array of our shields (life)

func _ready() -> void:
	for child in $Control/HFlowContainer.get_children(): #for each shield in the container append them to array 
		if child is ShieldGUI:
			shields.append( child )
			print("Shields size:", shields.size())
			child.visible = false #turn visibility off
	
	hide_game_over_screen()
	try_again_button.pressed.connect( reset_level )
	title_button.pressed.connect( return_to_title )
	GlobalLevelManager.level_loaded.connect( hide_game_over_screen )
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


func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)

func show_game_over_screen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	animation_player.play("game_over_screen")
	await animation_player.animation_finished
	
	try_again_button.grab_focus()
	pass


func reset_level() -> void:
	await fade_to_black()
	GlobalLevelManager.load_new_level(level_1, "", Vector2.ZERO)
	pass


func fade_to_black() -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	GlobalPlayerManager.knight.revive_player() #heal player
	pass


func return_to_title() -> void:
	await fade_to_black()
	GlobalLevelManager.load_new_level(title_screen, "", Vector2.ZERO)
	pass
