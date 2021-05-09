extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if owner.is_on_floor() and owner.owner.velocity.x == 0:
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
	elif owner.is_on_floor() and owner.owner.velocity.x != 0:
		owner.movement_state_machine.change_state(owner.MS_RunState.new(owner))
	
	if owner.owner.velocity.y >= owner.movement_module.jump_force:
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
		
func exit():
	pass

func get_name():
	return "DoubleJump"
