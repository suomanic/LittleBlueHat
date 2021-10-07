extends State

func _init(o).(o):
	pass

func enter():
	owner.collision_module.change_to_normal_collision()
	owner.element_state = "Normal"
	
	
	pass
	
func execute():
	
	pass

func exit():
	pass

func get_name():
	return ""
