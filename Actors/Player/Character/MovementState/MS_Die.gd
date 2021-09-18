extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	pass

func exit():
	pass

func get_name():
	return "MS_Die"
