extends State

func _init(o).(o):
	pass

func enter():
	owner.owner.movement_anim_player.play("Up_Anim")
	pass
	
func execute():
	if owner.owner.velocity.y > -owner.owner.movement_module.jump_force:
		owner.Air_State_Machine.change_state(owner.AS_UptoFallState.new(owner))

func exit():
	pass

func get_name():
	return ""
