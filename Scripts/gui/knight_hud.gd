extends CanvasLayer

const level_1 : String = "res://Scenes/levels/level_1.tscn"
const title_screen : String = "res://Scenes/levels/title_screen.tscn"

@onready var game_over: Control = $Control/GameOver
@onready var try_again_button: Button = $Control/GameOver/HBoxContainer/TryAgainButton
@onready var title_button: Button = $Control/GameOver/HBoxContainer/TitleButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var auto_save_animation_player: AnimationPlayer = $Control/AutosavePopup/AutoSave_AnimationPlayer
@onready var stamina_progress_bar: ProgressBar = $Control/StaminaBarContainer/ProgressBar

var decrease_stamina_value : float = 0.0
var increase_stamina_value : float = 0.0
var increasing_stamina : bool = false
var decreasing_stamina : bool = false
var shields : Array[ ShieldGUI ] = [] #array of our shields (life)

func _ready() -> void:
	for child in $Control/ShieldContainer.get_children(): #for each shield in the container append them to array 
		if child is ShieldGUI:
			shields.append( child )
			print("Shields size:", shields.size())
			child.visible = false #turn visibility off
			
	hide_game_over_screen()
	try_again_button.pressed.connect( reset_level )
	title_button.pressed.connect( return_to_title )
	GlobalLevelManager.level_loaded.connect( hide_game_over_screen )
	pass


func _process(_delta: float) -> void:
	if decreasing_stamina:#lose stam
		stamina_progress_bar.value -= decrease_stamina_value
	if increasing_stamina:#increase stam
		stamina_progress_bar.value += decrease_stamina_value


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


func set_stamina( _stam : float ) -> void: #sets stamina to a flat value
	var _value : float = clampf( _stam, 0.0, 100.0) #clamp between 0 and 100
	stamina_progress_bar.value = _value
	pass


func decrease_stamina( _stam : float ) -> void: #decrease stamina based on pass in value
	decrease_stamina_value = _stam
	decreasing_stamina = true
	increasing_stamina = false
	pass


func increase_stamina( _stam : float ) -> void: #increase stamina based on pass in value
	increase_stamina_value = _stam
	increasing_stamina = true
	decreasing_stamina = false
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


func auto_save_popup() -> void:
	auto_save_animation_player.play("autosave_fade_in_out")
	pass

func save_popup() -> void:
	auto_save_animation_player.play("save_fade_in_out")
	pass


func return_to_title() -> void:
	await fade_to_black()
	GlobalLevelManager.load_new_level(title_screen, "", Vector2.ZERO)
	pass
