extends State

var counter

func _init(o).(o):
	pass

func enter():
	owner.moving_finished = false
	counter = 0.55
	owner.anim_player.play("N_Move_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	
	if counter < 0:
		owner.state_machine.change_state(owner.IdleState.new(owner))
	pass

func exit():
	owner.moving_finished = true
	pass

func get_name():
	return "move"
	

