extends State

func _init(o).(o):
	pass

func enter():
	owner.can_change_element = false
	
	owner.anim_player.play("ItoN_Anim")
	owner.element_state = "Normal"
	owner.collision_module.ItoN_collision_change()
	pass
	
func execute():
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return ""
