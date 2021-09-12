extends State

func _init(o).(o):
	pass

func enter():
	owner.movement_module.squish_damage_move(owner.collision_module.will_go_left)
	pass
	
func execute():
	
	pass

func exit():
	pass

func get_name():
	return ""
