extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("F_Chase_Anim")
	pass
	
func execute():
	if owner.player != null:
		if owner.is_moving_left == (owner.global_position.x - owner.player.global_position.x < 0):
			owner._turn_around()
	
	if owner.is_moving_finished and owner.element_change_count < 0 and (owner.element_state == "Fire"):
		if owner.player == null:
			owner.state_machine.change_state(owner.F_IdleState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "F_Chase"
