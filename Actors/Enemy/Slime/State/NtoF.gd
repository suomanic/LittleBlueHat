extends State

func _init(o).(o):
	pass

func enter():
	owner.can_change_element = false
	
	owner.anim_player.play("NtoF_Anim")
	owner.element_state = "Fire"
	owner.collision_module.change_fire_collision()
	pass
	
func execute():
	pass

func exit():
	owner.can_change_element = true
	pass

func get_name():
	return "move"
