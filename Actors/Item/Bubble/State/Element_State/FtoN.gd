extends State

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Normal"
	owner.character_shadow_sprite.set_modulate("ffffff")
	owner.will_move = true
	owner.move_target = owner.normal_absolute_position
	pass
	
func execute():
	pass

func exit():
	pass

static func get_name():
	return ""
