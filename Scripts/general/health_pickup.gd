class_name HealthPickup extends Area2D

@export var pickup_audio : AudioStream
@export var audio_volume : float 

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if audio:
		audio.stream = pickup_audio #set audio track
		audio.volume_db = audio_volume
	area_entered.connect(_on_player_entered)
	pass


func _on_player_entered( _area: Area2D ) -> void:
	if _area is InteractArea:
		var audio_player : AudioStreamPlayer2D = audio.duplicate() #duplicate audio player so audio doesnt get cut off by queue free
		get_parent().add_child(audio_player)  #add to scene
		audio_player.global_position = global_position #set position
		audio_player.play() 
		audio_player.finished.connect(audio_player.queue_free) #queue free the duplicate once done
		
		GlobalPlayerManager.knight.update_hp(1) #heal 1 hp
		queue_free() #free node
	else:
		return
