extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if owner.velocity.y > 0:
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
	if owner.input_module.is_jump_pressed:
		owner.movement_state_machine.change_state(owner.MS_DoubleJumpState.new(owner))
	
	
	pass

func exit():
	pass

func get_name():
	return "Up"
