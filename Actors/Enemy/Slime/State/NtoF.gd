extends State

signal change_to_fire()

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("NtoF_Anim")
	owner.element_state = "Fire"
	owner.collision_module.change_fire_collision()
#	connect("change_to_fire",owner.collision_module,"change_fire_collision")
	emit_signal("change_to_fire")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return "move"
