extends Control

@export var audio : AudioStream

@onready var labels: Control = $Labels


func _ready() -> void:
	GlobalAudioManager.play_music(audio)
	GlobalPlayerManager.process_mode = Node.PROCESS_MODE_DISABLED
	GlobalPlayerManager.knight.visible = false
	KnightHud.visible = false #turn off hud
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED#turn off pause menu
	start_credits()
	pass

func start_credits() -> void:
	var start_pos = Vector2(labels.position.x, size.y - 200) # below screen
	var end_pos = Vector2(labels.position.x, -labels.size.y - 850) # offscreen above
	
	labels.position = start_pos
	
	var tween = create_tween() #move screen down
	tween.tween_property(labels, "position", end_pos, 30.0)
	pass


func _process(_delta: float) -> void: #skip credits
	if Input.is_action_pressed("pause"):
		GlobalLevelManager.load_new_level("res://Scenes/levels/title_screen.tscn", "", Vector2.ZERO)
