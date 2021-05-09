extends State

func _init(o).(o):
	pass

func enter():
	owner.owner.animation_player.play("Idle_Anim")
	pass
	
func execute():
	if owner.owner.owner.velocity.x != 0 :
		owner.Ground_State_Machine.change_state(owner.AS_RunState.new(owner))
		
	if owner.owner.owner.input_module.is_crouch_pressed:
		owner.Ground_State_Machine.change_state(owner.AS_CrouchState.new(owner))
	pass

func exit():
	pass

func get_name():
	return ""
