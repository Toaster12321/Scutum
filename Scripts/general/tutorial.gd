class_name Tutorial extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_cutscene_detection_2: PlayerCutsceneDetection = $"../PlayerCutsceneDetection2"
@onready var tutorial_finished: Area2D = $tutorial_finished


func _ready() -> void:
	player_cutscene_detection_2.cutscene_finished.connect(play_tutorial)
	tutorial_finished.area_entered.connect(stop_tutorial)
	pass


func play_tutorial() -> void:
	animation_player.play("fade_in")


func stop_tutorial(area : Area2D) -> void:
	if area:
		animation_player.play("fade_out")
