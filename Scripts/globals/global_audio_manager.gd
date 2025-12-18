extends Node

var music_audio_player_count : int = 2
var current_music_player : int = 0
var music_players : Array[ AudioStreamPlayer ] = []
var music_bus : String = "Music" #only fades in/out on music tracks

var music_fade_duration : float = 0.5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS #set to always to not hiccup volume
	for i in music_audio_player_count: #for all players
		var player = AudioStreamPlayer.new() #get player
		add_child( player ) #add it to the scene tree 
		player.bus = music_bus #set bus
		music_players.append( player )  #append player to array and set volume
		player.volume_db = -40 #set volume to 0


func play_music( _audio : AudioStream ) -> void:
	if _audio == music_players[ current_music_player ].stream: #if the track is the current track return
		return
	
	current_music_player += 1 #increment music player count
	if current_music_player > 1:
		current_music_player = 0 #cycle over 
	
	var current_player : AudioStreamPlayer = music_players[ current_music_player ] #get the current player
	current_player.stream = _audio #play audio
	play_and_fade_in( current_player )
	
	var old_player = music_players[ 1 ] #set old player 
	if current_music_player == 1:
		old_player = music_players[ 0 ]
	
	fade_out_and_stop( old_player ) 

func play_and_fade_in( player : AudioStreamPlayer ) -> void:
	player.play( 0 ) #plays sound from beginning
	var tween : Tween = create_tween()
	tween.tween_property( player, 'volume_db', 0, music_fade_duration ) # tween volume in
	pass


func fade_out_and_stop( player : AudioStreamPlayer ) -> void:
	var tween : Tween = create_tween()
	tween.tween_property( player, 'volume_db', -40, music_fade_duration ) #tween volume out
	await tween.finished
	player.stop()
	pass


func stop_music() -> void:
	var current_player : AudioStreamPlayer
	current_player = music_players[ current_music_player ]
	fade_out_and_stop(current_player)
