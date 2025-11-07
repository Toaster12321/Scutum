class_name Messor extends CharacterBody2D

const SUMMON_SCENE : PackedScene = preload("res://Scenes/enemies/summon_enemy.tscn")

signal direction_changed( new_direction : Vector2 )

@export var max_hp : int = 10
@export var move_speed : float = 50.0

var hp : int = 10
var summon_count : int = 0
var direction : Vector2 = Vector2.ZERO
var summon_target : Vector2
var return_target : Vector2
var facing_direction : float = 1
var attack_delay_over : bool = true
var finding_player : bool = true
var moving_to_summon : bool = false
var returning_to_floor = false
var player_seen : bool = false
var attack_select : int
var summons : Array[Node2D]

@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer
@onready var boss_effect_animation_player: AnimationPlayer = $BossEffectAnimationPlayer
@onready var sprite: Node2D = $BossNode
@onready var cast_shadow: ClassShadow = $BossNode/BossSprite/CastShadow
@onready var vision_area: VisionArea = $BossNode/VisionArea
@onready var timer: Timer = $Timer


func _ready() -> void:
	$SummoningPositions.visible = false
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) )
	vision_area.player_enetered.connect( _on_knight_entered )
	vision_area.player_exited.connect( _on_knight_exited )
	
	hp = max_hp #set boss hp to full
	
	hitbox.damaged.connect( _on_damage_taken )
	
	find_player()
	pass


func _process(delta: float) -> void:
	attack_select = randi_range(0,2) #random var for attack
	move_and_slide() #allows movement in scene
	
	if finding_player == true:  #if we are finding the player
		velocity.y += 980 * delta #apply gravity
		
		var dir_to_player = position.direction_to(GlobalPlayerManager.knight.global_position) 
		dir_to_player.y = 0
		velocity = dir_to_player.normalized() * move_speed #move in the direction of player only in the x axis, y is gravity
	 
	if moving_to_summon == true: #if we are summoning turn off hitbox and vision area
		hitbox.monitorable = false
		vision_area.monitoring = false
		finding_player = false #not finding the player
		var summon_spot = get_tree().current_scene.get_node("BossSummonPosition")
		if summon_spot:
			summon_target = summon_spot.global_position
			velocity = position.direction_to(summon_target) * 70 #move towards the summon spot location with 70 move speed
		
		if global_position.distance_to(summon_target) < 1.0: #if we reached the summon target we arent moving and go to summon state
			moving_to_summon = false
			velocity = Vector2.ZERO
			summon()
	
	if returning_to_floor == true: #after summoning we are returning to the floor
		hitbox.monitorable = true #turn hitbox back on
		var return_spot = get_tree().current_scene.get_node("BossReturnPosition")
		if return_spot:
			return_target = return_spot.global_position
			velocity = position.direction_to(return_target) * move_speed#move towards the return target location
		
		if global_position.distance_to(return_target) < 1.0: #if we reached the return target turn vision area back on and find the player
			returning_to_floor = false
			vision_area.monitoring = true
			find_player()


func _on_damage_taken( _hurtbox : Hurtbox ) ->  void:
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) ) #set direction towards player
	if boss_effect_animation_player.current_animation == "flash" or _hurtbox.damage == 0: #gives i frames to boss when hit
		return
	hp = clampi( hp - _hurtbox.damage, 0, max_hp) #clamp hp so hp cant fall lower than 0
	boss_effect_animation_player.play("flash")
	boss_effect_animation_player.seek( 0 ) #set to first frame and queue default just in case
	boss_effect_animation_player.queue("default")
	
	if hp == 7 or hp == 3: #if boss reaches 7 or 3 hp -> summon phase
		timer.stop()
		boss_animation_player.play("idle")
		moving_to_summon = true
	
	if hp < 1: #if the boss is dead stop any timers and go to death state
		timer.stop()
		boss_defeated()
		


func boss_defeated() -> void:
	cast_shadow.queue_free() #get rid of shadow 
	boss_animation_player.play("death")
	set_hit_boxes(false) #turn off hit detection
	
	await boss_animation_player.animation_finished
	
	queue_free() #remove from scene
	pass


func set_hit_boxes( _bool : bool = true ) -> void: #sets hit/hurtbox status
	hitbox.set_deferred("monitorable", _bool)
	hurtbox.set_deferred("monitoring", _bool)
	pass


func find_player() -> void:
	if player_seen == true: #if the player is still in vision keep attacking
		_on_knight_entered()
		return
		
	set_direction( global_position.direction_to(GlobalPlayerManager.knight.global_position) ) #set direction towards player
	boss_animation_player.play("idle")
	finding_player = true #finding player
	pass


func set_direction( _new_direction : Vector2 ) -> void:
	if _new_direction != Vector2.ZERO: #if the new direction isnt zero change to the new one
		direction = _new_direction
		
		if direction.x < 0: 
			sprite.scale.x = -1 #if we are facing right flip left
			facing_direction = 1
		elif direction.x > 0: 
			sprite.scale.x = 1 #if we are facing left flip right
			facing_direction = -1
	
	direction_changed.emit( direction ) #emit signal for direction changed to switch any nodes to new direction


func _on_knight_entered() -> void:
	player_seen = true #found player and seen now attack in place
	finding_player = false
	velocity = Vector2.ZERO
	
	if attack_delay_over == true: #if the 1 second delay is up attack again
		match attack_select:
			0:
				boss_animation_player.play("double_attack_" + anim_direction())
			1:
				boss_animation_player.play("single_attack_" + anim_direction())
			2:
				boss_animation_player.play("skill")
			
		await boss_animation_player.animation_finished
		boss_animation_player.play("idle2")
		attack_delay_over = false #just attacked now delay
		
	timer.start(0.75) #wait 0.75 sec between attacks
	await timer.timeout
	
	attack_delay_over = true #delay over
	
	find_player() #check to see if the player is still in vision or gone
	pass


func _on_knight_exited():
	player_seen = false #player left vision cone


func anim_direction() -> String: #returns a left or right based on the current direction of the player
	if direction.x < 0:
		return "left"
	else:
		return "right"


func summon() -> void:
	summon_count += 1 #how many times has the boss summoned
	boss_animation_player.stop()
	boss_animation_player.play("summon") 
	for c in $SummoningPositions.get_children(): #get summon positions
		summons.append(c) 
	
	if summons.size() == 0: 
		print("no positions found")
	
	var summon1 : Node2D = SUMMON_SCENE.instantiate() #instatiate summons
	var summon2 : Node2D = SUMMON_SCENE.instantiate()
	var summon3 : Node2D = SUMMON_SCENE.instantiate()
	var summon4 : Node2D = SUMMON_SCENE.instantiate() 
	var summon5 : Node2D = SUMMON_SCENE.instantiate()
	var summon6 : Node2D = SUMMON_SCENE.instantiate()
	
	get_parent().add_child.call_deferred( summon1 ) #add spells as a child to the enemy
	get_parent().add_child.call_deferred( summon2 )
	get_parent().add_child.call_deferred( summon3 )
	
	summon1.global_position = summons[0].global_position #set their position to the indicator set in editor
	summon2.global_position = summons[1].global_position
	summon3.global_position = summons[2].global_position
	
	if summon_count == 2: #if this is the second summon add 3 more summons
		get_parent().add_child.call_deferred( summon4 )
		get_parent().add_child.call_deferred( summon5 )
		get_parent().add_child.call_deferred( summon6 )
		summon4.global_position = summons[3].global_position 
		summon5.global_position = summons[4].global_position
		summon6.global_position = summons[5].global_position
	
	await boss_animation_player.animation_finished
	boss_animation_player.play("idle2")
	returning_to_floor = true #return to floor position
	moving_to_summon = false #no longer summmoning
	pass
