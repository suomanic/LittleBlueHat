extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.crouch_move()
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	owner.collision_module.is_facing_left = owner.collision_module.facing()
	
	if !owner.movement_module.is_on_object or !owner.owner.input_module.is_crouch_pressed:
		if owner.velocity.y != 0:
			owner.movement_state_machine.change_state(owner.MS_FallState.new(owner)) 
		
		if owner.velocity.x == 0:
			owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner)) 
		elif owner.velocity.x != 0:
			owner.movement_state_machine.change_state(owner.MS_RunState.new(owner)) 
		
	elif owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
		
	elif owner.velocity.y < 0 :
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "MS_Crouch"
