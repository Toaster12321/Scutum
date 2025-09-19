extends Node

const START_LEVEL : String = "res://Scenes/levels/level_1.tscn" #path to 1st level

@export var title_music : AudioStream

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var start_button: Button = $CanvasLayer/Control/StartButton
@onready var shield_animation_player: AnimationPlayer = $CanvasLayer/Control/ShieldAnimationPlayer
@onready var title_animation_player: AnimationPlayer = $CanvasLayer/Control/TitleAnimationPlayer



func _ready() -> void:
	get_tree().paused = true #pause all other normal functions
	GlobalPlayerManager.knight.visible = false #turn off knight
	
	KnightHud.visible = false #turn off hud
	
	setup_title_screen()
	
	GlobalLevelManager.level_load_started.connect( exit_title_screen ) #once level loaded has been emitted
	
	pass


func setup_title_screen() -> void:
	GlobalAudioManager.play_music( title_music ) #play music
	start_button.pressed.connect( start_game ) #connect start button function
	
	shield_animation_player.play("default_shield") #play animations
	title_animation_player.play("default_title")
	pass


func start_game() -> void:
	GlobalLevelManager.load_new_level( START_LEVEL, "", Vector2.ZERO ) #load start level
	pass


func exit_title_screen() -> void:
	GlobalPlayerManager.knight.visible = true # turn on knight
	KnightHud.visible = true # turn on hud
	self.queue_free() #get rid of title screen
	pass
