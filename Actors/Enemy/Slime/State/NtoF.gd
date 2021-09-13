extends State

func _init(o).(o):
	pass

func enter():
	owner.element_change_count = owner.element_change_time
	
	owner.anim_player.play("NtoF_Anim")
	owner.element_state = "Fire"
	owner.collision_module.change_fire_collision()
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return "move"
