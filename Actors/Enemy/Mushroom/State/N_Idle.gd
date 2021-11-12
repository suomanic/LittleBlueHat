extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("N_Idle_Anim")
	pass
	
func execute():
	pass

func exit():
	pass

static func get_name():
	return ""
