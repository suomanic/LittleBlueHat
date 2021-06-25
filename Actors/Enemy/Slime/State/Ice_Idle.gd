extends State

func _init(o).(o):
	pass

func enter():
	owner.velocity.x = 0
	owner.anim_player.play("I_Idle_Anim")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return ""
