extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	owner.collision_module.is_facing_left = owner.collision_module.facing()
	
	if (owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0)|| owner.velocity.y < 0:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
	
	if owner.velocity.x == 0 and owner.movement_module.is_on_object:
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
		
	elif owner.movement_module._coyote_counter < 0  and owner.velocity.y > 0:
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
	if owner.owner.input_module.is_crouch_pressed and owner.movement_module.is_on_object:
		owner.movement_state_machine.change_state(owner.MS_CrouchState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "MS_Run"
