extends State

func _init(o).(o):
	pass

func enter():
	owner.animation_player.play("toCrouch_Anim")
	pass
	
func execute():
	owner.move()
	pass

func exit():
	pass

func get_name():
	return "Crouch"
