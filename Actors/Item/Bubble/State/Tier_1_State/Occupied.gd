extends State

signal eject_signal

func _init(o).(o):
	pass

func enter():
	owner.arrow_sprite.set_visible(true)
	pass
	
func execute():
	owner.arrow_sprite_movement()
	
	if owner.character.get_parent().input_module.is_attack_just_pressed:
		connect("eject_signal",owner.character,"ejected_from_bubble")
		emit_signal("eject_signal",owner.eject_angle)
		pass
	
	pass

func exit():
	owner.arrow_sprite.set_visible(false)
	pass

static func get_name():
	return "Occupied"
