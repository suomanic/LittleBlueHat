extends State

func _init(o).(o):
	pass

func enter():
	owner.animation_player.play("Hurt_Anim")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return ""
