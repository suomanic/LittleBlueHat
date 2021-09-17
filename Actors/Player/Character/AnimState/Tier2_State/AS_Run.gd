extends State

func _init(o).(o):
	pass

func enter():
	owner.owner.movement_anim_player.play("Run_Anim")
	pass
	
func execute():
	if owner.owner.velocity.x == 0:
		owner.Ground_State_Machine.change_state(owner.AS_IdleState.new(owner))
		
	if owner.owner.owner.input_module.is_crouch_pressed:
		owner.Ground_State_Machine.change_state(owner.AS_CrouchState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "AS_Run"
