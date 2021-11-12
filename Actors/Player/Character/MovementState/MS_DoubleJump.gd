extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	owner.collision_module.facing()
	
	if owner.movement_module.is_on_object and owner.velocity.x == 0:
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
	elif owner.movement_module.is_on_object and owner.velocity.x != 0:
		owner.movement_state_machine.change_state(owner.MS_RunState.new(owner))
	
	if owner.velocity.y >= owner.movement_module.jump_force:
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
		
func exit():
	pass

static func get_name():
	return "MS_DoubleJump"
