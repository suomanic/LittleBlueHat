extends Node

func _spring_area_entered(area: Area2D) -> void:
	if area.owner.element_state == "Normal" :
		owner.velocity.y = -300
		owner.movement_module.jump_count = 1
	elif area.owner.element_state == "Ice" :
		pass
