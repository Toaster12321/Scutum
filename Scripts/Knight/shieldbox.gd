class_name Shieldbox extends Area2D 

#signal that emits when hitbox has connected with another area2D or damaged
signal deflected( hurt_box : Hurtbox )

func shield_damage( hurt_box : Hurtbox ) -> bool: #function to shield damage based off passed hurtbox scene
	var owner = get_parent() #owner is the knight
	if owner == null:
		return false
	
	var attacker_dir = (hurt_box.global_position - owner.global_position) #which horizontal side the attack came from relative to the knight
	var attack_side = int(sign(attacker_dir.x)) #-1 left, 1 right, 0 if alinged
	
	var owner_facing_dir = GlobalPlayerManager.knight.facing_direction #-1 left, 1 right
	
	if attack_side == owner_facing_dir: #if attack side equals facing direction attack come front -> block
		deflected.emit(hurt_box)
		return true
	else: #take damage shielding in wrong direction
		owner._take_damage(hurt_box)
		return false
