extends State

var counter = randi() % 5 + 5

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("I_Idle_Anim")
	pass
	
func execute():
	counter -= owner.get_physics_process_delta_time()
	if counter < 0:
		owner.anim_player.play("I_Wink_Anim")
		counter = randi() % 5 + 5

func exit():
	pass

static func get_name():
	return ""
