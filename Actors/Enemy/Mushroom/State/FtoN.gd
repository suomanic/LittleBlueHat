extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("FtoN_Anim")
	owner.can_change_element = false
	owner.collision_module.change_to_normal_collision()
	owner.element_state = "Normal"
	pass
	
func execute():
	pass

func exit():
	owner.can_change_element = true
	pass

func get_name():
	return ""
