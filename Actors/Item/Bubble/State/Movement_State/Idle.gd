extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	if owner.will_move:
		owner.movement_state_machine.change_state(owner.moveState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "Idle"
