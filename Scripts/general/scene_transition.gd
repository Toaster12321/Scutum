extends CanvasLayer
#script for fade in/ fade out screen transitions
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer


func fade_out() -> bool:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return true


func fade_in() -> bool:
	animation_player.play("fade_in")
	return true
