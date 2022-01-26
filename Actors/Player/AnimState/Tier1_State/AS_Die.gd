extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_anim_player.play("Die_Anim")
	pass

func exit():
	pass

static func get_name():
	return "AS_Die"
