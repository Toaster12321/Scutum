class_name ShieldGUI extends Control

@onready var sprite: Sprite2D = $Sprite2D

var value : int = 2 : # set value to 2
	set ( _value ):
		value = _value # update value
		update_sprite()


func update_sprite() -> void: 
	sprite.frame = value #set sprite frame to 2 (full shield)
