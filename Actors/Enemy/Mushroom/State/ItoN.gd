extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("ItoN_Anim")
	owner.collision_module.change_to_normal_collision()
	owner.element_state = "Normal"
	owner.can_change_element = false
	
	pass
	
func execute():
	
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return ""
