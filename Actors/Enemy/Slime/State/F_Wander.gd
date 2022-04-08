extends State

var counter

func _init(o).(o):
	pass

func enter():
	owner.movement_module.is_moving_finished = false
	counter = 0.9
	owner.anim_player.play("F_Move_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	
	owner.movement_module.F_move()
	
	if owner.f_ray_cast.is_colliding() and !owner.b_ray_cast.is_colliding():
		owner._turn_around()
	
	if counter < 0:
		owner.state_machine.change_state(owner.F_IdleState.new(owner))
	pass

func exit():
	owner.movement_module.is_moving_finished = true
	pass

static func get_name():
	return "F_Wander"
	
	

