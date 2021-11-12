extends State

func _init(o).(o):
	pass

func enter():
	owner.can_change_element = false
	
	owner.anim_player.play("NtoI_Anim")
	owner.element_state = "Ice"
	owner.collision_module.change_ice_collision()
	pass
	
func execute():
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return "move"
