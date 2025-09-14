class_name KnightStateCrouch extends KnightState

@export var deceleration : float = 5
@onready var collision_shape_2d: CollisionShape2D = $"../../CollisionShape2D" #collision shapes for normal + crouch sprites
@onready var collision_shape_2d_crouch: CollisionShape2D = $"../../CollisionShape2D_Crouch" 
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var camera_2d: Camera2D = $"../../Camera2D"

var in_crouch : bool = false #bool to see if we are in the crouch state

func ready() -> void:
	pass


func init() -> void:
	ray_cast_2d.enabled = false
	pass


func enter() -> void:
	in_crouch = true #crouching
	knight.animation_player.play("crouch")
	ray_cast_2d.enabled = true #enable raycast
	collision_shape_2d.disabled = true #disable normal collision shape
	collision_shape_2d_crouch.disabled = false #enable crouch collision shape
	
	await get_tree().create_timer( 1 ).timeout #after 1 second move camera down
	
	if in_crouch: #make sure we are crouching to perform this
		var tween  = get_tree().create_tween() #tween for smoothing
		tween.tween_property(camera_2d, "position:y", knight.default_cam_position + 70, 0.4) #move camera down 70 pixels for 0.4s
	
	pass


func exit() -> void: #disable crouch collision and revert to normal collision
	in_crouch = false #no longer crouching
	collision_shape_2d.disabled = false #re-enable normal collision shape
	collision_shape_2d_crouch.disabled = true #disable crouch collision shape
	ray_cast_2d.enabled = false #disable raycast
	
	if knight.camera_2d.position.y != knight.default_cam_position: #if the camera is not in the right position tween back up
		var tween  = get_tree().create_tween() #tween for smoothing
		tween.tween_property(camera_2d, "position:y", knight.default_cam_position, 0.1) #move camera back up to default position in 0.2s for a fast return
	
	pass


func handle_input( _event : InputEvent ) -> KnightState:
	if _event.is_action_pressed("jump"): #allow transition to jump if pressed
		if ray_cast_2d.is_colliding() == true:
			knight.position.y += 2
			return fall
		return jump
	elif _event.is_action_pressed("attack"):  
		return attack
	elif _event.is_action_pressed("shield"):
		return shield
	return null


func process( _delta : float ) -> KnightState:
	
	return null


func physics_process( _delta : float ) -> KnightState:
	knight.update_velocity( 0 , deceleration ) #slows player down by deceleration value to a stop
	if direction.y <= 0: #we arent pressing the down key
		return idle
	elif not knight.is_on_floor(): #if not on floor go to fall state
		return fall
	return null
