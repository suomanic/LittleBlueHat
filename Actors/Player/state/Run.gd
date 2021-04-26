extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_state_machine.travel("Run_Anim")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return "Run"
