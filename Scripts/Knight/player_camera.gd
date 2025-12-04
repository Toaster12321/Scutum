class_name PlayerCamera extends Camera2D
#screen shake on hit
@export var noise_texture : NoiseTexture2D

var shake_time : float = 0.0
var strength : float = 20
var speed : float = 300

var noise_y : float = 0  
var noise_x : float = 1

func _ready() -> void: #connect signal globally
	GlobalSignalManager.on_camera_feedback_requested.connect(on_camera_feedback_requested)

func _physics_process(delta: float) -> void:
	
	if shake_time > 0.0: #start shake time
		shake_time -= delta
		
		var shake_offset : Vector2 = get_noise_offset(delta)
		
		offset.x = shake_offset.x #set camera's native offset to the shake offset of the noise assigned
		offset.y = shake_offset.y
		
	else:
		offset.x = 0
		offset.y = 0


func get_noise_offset( _delta : float ) -> Vector2:
	noise_y += _delta * speed #get nosie y from delta and speed
	
	var _offset : Vector2 = Vector2.ZERO
	
	if noise_texture.noise:
		var noise : FastNoiseLite = noise_texture.noise
		_offset.x = noise.get_noise_2d(noise_x, noise_y) * strength #get noise's x and y range for x offset
		_offset.y = noise.get_noise_2d(noise_x * randf_range(50,100), noise_y) * strength #get noise's x randomly and y range for y offset
	
	return _offset


func _shake_camera(_amount : float, duration : float, _speed : float) -> void:
	strength = _amount #assign variables
	shake_time = duration
	speed = _speed


func on_camera_feedback_requested( _amount : float, _duration : float, _speed : float) -> void:
	_shake_camera(_amount, _duration, _speed)
