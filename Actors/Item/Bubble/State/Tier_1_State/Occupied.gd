extends State

signal eject_signal

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.arrow_sprite_movement()
	
	if owner.character.get_parent().input_module.is_attack_just_pressed:
		connect("eject_signal",owner.character,"ejected_from_bubble")
		emit_signal("eject_signal",owner.eject_angle)
		owner.state_machine.change_state(owner.ejectState.new(owner))
		pass
	
	pass

func exit():
	pass

static func get_name():
	return "Occupied"
