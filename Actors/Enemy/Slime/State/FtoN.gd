extends State

func _init(o).(o):
	pass

func enter():
	owner.element_change_count = owner.element_change_time
	
	owner.anim_player.play("FtoN_Anim")
	owner.element_state = "Normal"
	owner.collision_module.FtoN_collision_change()
	pass
	
func execute():
	pass

func exit():
	
	pass

static func get_name():
	return ""
