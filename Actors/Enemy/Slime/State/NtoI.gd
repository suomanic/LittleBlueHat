extends State

func _init(o).(o):
	pass

func enter():
	owner.element_change_count = owner.element_change_time
	
	owner.anim_player.play("NtoI_Anim")
	owner.element_state = "Ice"
	owner.collision_module.change_ice_collision()
	pass
	
func execute():
	pass

func exit():
	pass

static func get_name():
	return "move"
