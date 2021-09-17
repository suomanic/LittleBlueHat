extends State

func _init(o).(o):
	pass

func enter():
	owner.owner.movement_anim_player.play("toCrouch_Anim")
	pass
	
func execute():
	if !owner.owner.owner.input_module.is_crouch_pressed:
		if owner.owner.velocity.x == 0:
			owner.Ground_State_Machine.change_state(owner.AS_IdleState.new(owner))
		else:
			owner.Ground_State_Machine.change_state(owner.AS_RunState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "AS_Crouch"
