extends State

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Normal"
	owner.bubble_anim_player.play("N_Idle_anim")
	pass
	
func execute():
	pass

func exit():
	pass

static func get_name():
	return "N_Idle"
