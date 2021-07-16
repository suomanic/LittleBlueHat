extends State

var counter = 1.5

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	if owner.is_moving_left != (owner.global_position.x - owner.player.global_position.x < 0):
		owner._turn_around()
	
	counter -= owner.get_physics_process_delta_time()
	if counter < 0:
		owner.anim_player.play("F_Move_Anim")
		counter = 1.5
	pass

func exit():
	pass

func get_name():
	return ""
