extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if owner.owner.velocity.x !=0 and !owner.is_on_wall():
		owner.movement_state_machine.change_state(owner.MS_RunState.new(owner)) 
		
	elif owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
		
	elif owner.owner.velocity.y < 0 :
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
		
	if owner.owner.input_module.is_crouch_pressed:
		owner.movement_state_machine.change_state(owner.MS_CrouchState.new(owner))
	
func exit():
	pass

func get_name():
	return "Idle"
