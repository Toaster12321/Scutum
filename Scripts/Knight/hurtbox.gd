class_name Hurtbox extends Area2D

signal did_damage #signal that calls if damage was dished out
signal blocked #signal that calls if damage was blocked

enum HurtboxType { BODY, WEAPON }

@export var hurtbox_type : HurtboxType = HurtboxType.BODY
@export var damage : int = 1 #variable damage int



func _ready() -> void:
	area_entered.connect( entered_area ) # if the hurtbox has been entered call the entered area function
	pass

func entered_area( area : Area2D ) -> void: #pass in the area connecting
	if area is Hitbox: #if it was a hitbox we are doing damage so call signal
		did_damage.emit()
		area.take_damage( self ) #take damage to attached entity
	elif area is Shieldbox: #if it was a shieldbox we are shielding so call signal
		blocked.emit()
		area.shield_damage( self ) #shield damage
	pass
