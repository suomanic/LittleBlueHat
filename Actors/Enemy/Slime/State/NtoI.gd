extends State

signal change_to_ice()

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("NtoI")
	owner.element_state = "Ice"
	connect("change_to_ice",owner.collision_module,"change_ice_collision")
	emit_signal("change_to_ice")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return "move"
