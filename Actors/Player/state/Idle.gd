extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_state_machine.travel("Idle_Anim")
	print_debug("had into idle state")
	pass
	
func execute():
	if owner.velocity.x != 0 and owner.is_on_floor():
		owner.state_machine.change_state(owner.RunState.new(owner)) 
	
	
func exit():
	pass

func get_name():
	return "Idle"
