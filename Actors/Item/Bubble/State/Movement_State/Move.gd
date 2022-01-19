extends State

var time = 0

func _init(o).(o):
	pass

func enter():
	owner.will_move = false
	owner.move_time = 0
	owner.current_absolute_position = owner.global_position
	pass
	
func execute():
	owner.move(owner.move_target)
	
	if owner.will_move:
		owner.movement_state_machine.change_state(owner.moveState.new(owner))

func exit():
	pass

static func get_name():
	return "Move"
