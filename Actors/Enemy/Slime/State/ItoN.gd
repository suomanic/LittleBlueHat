extends State

signal ice_to_normal()

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("ItoN_Anim")
	owner.element_state = "Normal"
	connect("ice_to_normal",owner.collision_module,"ItoN_collision_change")
	emit_signal("ice_to_normal")
	pass
	
func execute():
	pass

func exit():
	
	pass

func get_name():
	return ""
