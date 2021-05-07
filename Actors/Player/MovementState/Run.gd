extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if (owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0)|| owner.velocity.y < 0:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
	
	if owner.velocity.x == 0 and owner.is_on_floor():
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
		
	elif owner.movement_module._coyote_counter < 0  and owner.velocity.y > 0:
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
	if owner.input_module.is_crouch_pressed:
		owner.movement_state_machine.change_state(owner.MS_CrouchState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "Run"
