extends State

func _init(o).(o):
	pass

func enter():
	owner.movement_module.move()
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if owner.is_on_floor():
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
	elif owner.owner.velocity.y < 0 :
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
		
	if owner.owner.input_module.is_jump_pressed:
		owner.movement_state_machine.change_state(owner.MS_DoubleJumpState.new(owner))
		
	


func exit():
	pass

func get_name():
	return "Fall"
