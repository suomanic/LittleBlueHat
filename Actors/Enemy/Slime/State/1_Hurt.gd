extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("Hurt_Anim")
	
	if owner.is_hurt_move_left:
		owner.velocity.x = 50
	else :
		owner.velocity.x = -50
	owner.velocity.y = -50
	pass
	
func execute():
	pass

func exit():
	owner.velocity.x = 0
	pass

func get_name():
	return "move"
