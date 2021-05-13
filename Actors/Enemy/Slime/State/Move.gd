extends State

var counter = 3 

func _init(o).(o):
	pass

func enter():
	counter = 3
	owner.anim_player.play("Move_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	
	if counter < 0:
		owner.state_machine.change_state(owner.MoveState.new(owner))
	pass

func exit():
	pass

func get_name():
	return ""
