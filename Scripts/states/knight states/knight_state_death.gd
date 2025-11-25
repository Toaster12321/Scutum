class_name KnightStateDeath extends KnightState

@export var death_audio : AudioStream
@export var death_volume : float
var deceleration : float = 10.0

func init() -> void:
	pass


func enter() -> void:
	knight.animation_player.play("death")
	knight.play_audio(death_audio)
	knight.audio.volume_db = death_volume
	knight.hitbox.set_deferred("monitorable",false)
	KnightHud.show_game_over_screen()
	pass


func exit() -> void:
	
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	return null


func process( _delta : float ) -> KnightState:
	knight.update_velocity(0, deceleration)
	return null


func physics_process( _delta : float ) -> KnightState:
	return null
