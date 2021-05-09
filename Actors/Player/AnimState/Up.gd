extends State

func _init(o).(o):
	pass

func enter():
	print_debug("Up")
	owner.owner.animation_player.play("Up_Anim")
	pass
	
func execute():
	if owner.owner.owner.velocity.y > -owner.owner.movement_module.jump_force:
		owner.Air_State_Machine.change_state(owner.AS_UptoFallState.new(owner))

func exit():
	pass

func get_name():
	return ""
