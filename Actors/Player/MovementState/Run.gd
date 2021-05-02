extends State

func _init(o).(o):
	pass

func enter():
	owner.animation_player.play("Run_Anim")
	print_debug("Run")
	pass
	
func execute():
	owner.move()
	
	if (owner._coyote_counter > 0 and owner._jump_buffer_counter > 0)|| owner.velocity.y < 0:
		owner.state_machine.change_state(owner.UpState.new(owner))
	
	if owner.velocity.x == 0:
		owner.state_machine.change_state(owner.IdleState.new(owner))
		
	elif !owner.is_on_floor() and owner.velocity.y > 0:
		owner.state_machine.change_state(owner.FallState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "Run"
