extends Node

func _ready():
	pass

func change_ice_collision():
	owner.physic_collsion.call_deferred("change_to_ice_collision_box")

func change_fire_collision():
	owner.physic_collsion.call_deferred("change_to_fire_collision_box")

func ItoN_collision_change():
	owner.physic_collsion.call_deferred("change_to_normal_collision_box")

func FtoN_collision_change():
	owner.physic_collsion.call_deferred("change_to_normal_collision_box")
	
func _on_SquishHitBox_body_entered(body):
	if body.is_in_group("Slime") and body.can_cause_squish_damage :
		owner.physic_collsion.call("disable_squish_damage_collision")
		
		var will_go_left : bool
		
		if body.position.x - owner.position.x > 0 :
			will_go_left = false
		else:
			will_go_left = true
			
		owner.movement_module.squish_damage_move(will_go_left)
		pass
	pass # Replace	
	
func _on_Timer_timeout():
	owner.physic_collsion.call_deferred("enable_squish_damage_collision")
	pass # Replace with function body.
