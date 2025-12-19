class_name HealthPickup extends Area2D

@export var pickup_audio : AudioStream
@export var audio_volume : float 

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var pickup_id : String = "" 

func _ready() -> void:
	if pickup_id == "": 
		pickup_id = scene_file_path + ":" + str(global_position) #set unique ID for each health pickup
	
	if GlobalSaveManager.check_persistent_value(pickup_id): #if it has already been picked up queue_free on spawn
		queue_free()
		return
	
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
		
		GlobalPlayerManager.knight.update_hp(2) #heal 2 hp
		queue_free() #free node
		GlobalSaveManager.add_persistence_value(pickup_id) #add to persistence array as picked up
	else:
		return
