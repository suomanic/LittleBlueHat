extends State

func _init(o).(o):
	pass

func enter():
	owner.animation_tree.active = true
	owner.anim_state_machine.travel("Idle_Anim")
	owner.animation_player.stop(false)
	print_debug("Idle")
	pass
	
func execute():
	owner.move()
	
	if owner.velocity.x !=0 and !owner.is_on_wall():
		owner.state_machine.change_state(owner.RunState.new(owner)) 
		
	elif owner._coyote_counter > 0 and owner._jump_buffer_counter > 0:
		owner.state_machine.change_state(owner.JumpState.new(owner))
		
	elif owner.velocity.y < 0 :
		owner.state_machine.change_state(owner.UpState.new(owner))
	
func exit():
	owner.animation_player.stop(false)
	pass

func get_name():
	return "Idle"
