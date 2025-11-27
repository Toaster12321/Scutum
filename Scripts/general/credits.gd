extends Control

@onready var labels: Control = $Labels



func _ready() -> void:
	GlobalPlayerManager.process_mode = Node.PROCESS_MODE_DISABLED
	GlobalPlayerManager.knight.visible = false
	KnightHud.visible = false #turn off hud
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED#turn off pause menu
	start_credits()
	pass

func start_credits() -> void:
	var start_pos = Vector2(labels.position.x, size.y + 90) # below screen
	var end_pos = Vector2(labels.position.x, -labels.size.y - 50) # offscreen above
	
	labels.position = start_pos
	
	var tween = create_tween()
	tween.tween_property(labels, "position", end_pos, 20.0)
	#tween.finished.connect(_on_credits_finished)
	pass
