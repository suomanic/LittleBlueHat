extends State

var counter

func _init(o).(o):
	pass

func enter():
	counter = 0.55
	owner.anim_player.play("N_Move_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	
	owner.movement_module.N_move()
	
	if owner.f_ray_cast.is_colliding() and !owner.b_ray_cast.is_colliding():
		owner._turn_around()
	
	if counter < 0:
		owner.state_machine.change_state(owner.N_IdleState.new(owner))
	pass

func exit():
	pass

func get_name():
	return "move"
	

