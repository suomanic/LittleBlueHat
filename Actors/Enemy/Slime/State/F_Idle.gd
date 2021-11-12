extends State

var counter

func _init(o).(o):
	pass

func enter():
	counter = rand_range(2,3)
	owner.anim_player.play("F_Idle_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	
	if counter < 0:
		owner.state_machine.change_state(owner.F_WanderState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "move"
