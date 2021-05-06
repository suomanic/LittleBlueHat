extends State

func _init(o).(o):
	pass

func enter():
	print_debug("Crouch_Anim")
	owner.owner.animation_player.play("toCrouch_Anim")
	pass
	
func execute():
	if !owner.owner.input_module.is_crouch_pressed:
		if owner.owner.velocity.x == 0:
			owner.Ground_State_Machine.change_state(owner.AS_IdleState.new(owner))
		else:
			owner.Ground_State_Machine.change_state(owner.AS_RunState.new(owner))
	pass

func exit():
	pass

func get_name():
	return ""
