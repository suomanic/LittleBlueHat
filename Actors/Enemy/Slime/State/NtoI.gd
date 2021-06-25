extends State

signal change_to_ice()

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("NtoI")
	owner.element_state = "Ice"
	connect("change_to_ice",owner.collision_module,"ice_physic_collision")
	emit_signal("change_to_ice")
	
	if owner.is_hurt_move_left:
		owner.velocity.x = 50
	else :
		owner.velocity.x = -50
	owner.velocity.y = -50
	pass
	
func execute():
	pass

func exit():
	owner.velocity.x = 0
	pass

func get_name():
	return "move"
