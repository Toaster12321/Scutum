class_name KnightStateCrouch extends KnightState

@export var deceleration : float = 5
@onready var collision_shape_2d: CollisionShape2D = $"../../CollisionShape2D" #collision shapes for normal + crouch sprites
@onready var collision_shape_2d_crouch: CollisionShape2D = $"../../CollisionShape2D_Crouch" 
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var camera_2d: Camera2D = $"../../Camera2D"

var in_crouch : bool = false #bool to see if we are in the crouch state
var crouch_timer : float = 0.0

func ready() -> void:
	pass


func init() -> void:
	ray_cast_2d.enabled = false
	pass


func enter() -> void:
	in_crouch = true #crouching
	crouch_timer = 0.0
	knight.animation_player.play("crouch")
	ray_cast_2d.enabled = true #enable raycast
	collision_shape_2d.call_deferred("set_disabled",true) #re-enable normal collision shape
	collision_shape_2d_crouch.call_deferred("set_disabled",false) #disable crouch collision shape
	
	
	pass


func exit() -> void: #disable crouch collision and revert to normal collision
	crouch_timer = 0.0
	in_crouch = false #no longer crouching
	
	collision_shape_2d.call_deferred("set_disabled",false) #re-enable normal collision shape
	collision_shape_2d_crouch.call_deferred("set_disabled",true) #disable crouch collision shape
	ray_cast_2d.enabled = false #disable raycast
	
	if knight.camera_2d.position.y != knight.default_cam_position_y: #if the camera is not in the right position tween back up
		var tween  = get_tree().create_tween() #tween for smoothing
		tween.tween_property(camera_2d, "position:y", knight.default_cam_position_y, 0.2) #move camera back up to default position in 0.2s for a fast return
	
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if _event.is_action_pressed("jump"): #allow transition to jump if pressed
		if ray_cast_2d.is_colliding() == true:
			knight.drop_start_y = knight.global_position.y#where the knight is before he drops on the y axis
			knight.set_platform_collision(false) #turn off collision to fall through
			return fall
		return jump
	elif _event.is_action_pressed("attack"):  
		if knight.attack_locked:  #prevent attacking again if cooldown is still active
			return null
		return attack
	elif _event.is_action_pressed("shield"):
		return shield
	return null


func process( _delta : float ) -> KnightState:
	if in_crouch: #make sure we are crouching to perform this
		crouch_timer += _delta
		if crouch_timer >= 1.0 and camera_2d.position.y == knight.default_cam_position_y:
			var tween  = get_tree().create_tween() #tween for smoothing
			tween.tween_property(camera_2d, "position:y", knight.default_cam_position_y + 70, 0.4) #move camera down 70 pixels for 0.4s
	return null


func physics_process( _delta : float ) -> KnightState:
	knight.update_velocity( 0 , deceleration ) #slows player down by deceleration value to a stop
	if direction.y <= 0: #we arent pressing the down key
		return idle
	elif not knight.is_on_floor(): #if not on floor go to fall state
		return fall
	return null
