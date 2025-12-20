class_name KnightStateDeflect extends KnightState

@export var deflect_audio : AudioStream
@export var deflect_volume : float
@export var knockback_speed : float = 40.0

@onready var hitbox: Hitbox = $"../../Hitbox"
@onready var shieldbox: Shieldbox = $"../../ShieldHitbox"

var _anim_finished : bool = false

func init() -> void:
	pass


func enter() -> void:
	KnightHud.stamina_progress_bar.value -= 10.0 #lose 10 stamina on deflect
	knight.make_invulnerable(0.5)#extra i frames on deflect
	_anim_finished = false #animation hasnt finished
	knight.animation_player.animation_finished.connect( _on_anim_finished ) #connect to when deflect anim finishes
	
	knight.animation_player.play("shield_deflect")
	knight.audio.pitch_scale = randf_range( 0.9, 1.1 ) #make different pitch each deflect
	knight.audio.volume_db = deflect_volume
	knight.play_audio( deflect_audio )
	pass


func exit() -> void:
	_anim_finished = false #reset anim finished
	if knight.animation_player.animation_finished.is_connected( _on_anim_finished ):
		knight.animation_player.animation_finished.disconnect( _on_anim_finished ) #disconnect signal

	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if _anim_finished == true: #if the animation has finished allow for inputs
		if _event.is_action_pressed("jump") : #transition to jump state when button is pressed
			return jump
		elif _event.is_action_pressed("attack"): #transition to attack state when button is pressed
			if knight.attack_locked:  #prevent attacking again if cooldown is still active
				return null
			return attack
		elif _event.is_action_pressed("crouch"):
			return crouch
	return null


func process( _delta : float ) -> KnightState:
	#knight.velocity = Vector2.ZERO #make player stand still when hit
	knight.velocity.x = knight.facing_direction * -knockback_speed
	
	if _anim_finished == true: #if animation is over
		if Input.is_action_pressed("shield") : #if shield was held the whole time continue to shield
			return shield
		else:
			return idle #leave state
	return null


func physics_process( _delta : float ) -> KnightState:
	return null


func _on_anim_finished( _anim : String ) -> void:
	_anim_finished = true #animation has finished
	pass
