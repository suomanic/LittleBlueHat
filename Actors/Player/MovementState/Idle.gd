extends State

func _init(o).(o):
	pass

func enter():
	owner.animation_player.play("Idle_Anim")
	print_debug("Idle")
	
func execute():
	owner.movement_module.move()
	
	if owner.velocity.x !=0 and !owner.is_on_wall():
		owner.state_machine.change_state(owner.MS_RunState.new(owner)) 
		
	elif owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0:
		owner.state_machine.change_state(owner.MS_UpState.new(owner))
		
	elif owner.velocity.y < 0 :
		owner.state_machine.change_state(owner.MS_UpState.new(owner))
	
func exit():
	pass

func get_name():
	return "Idle"
