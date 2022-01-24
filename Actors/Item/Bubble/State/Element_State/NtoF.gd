extends State

var time = 0

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Fire"
	owner.character_shadow_sprite.set_modulate("fd7d29")
	owner.move_target = owner.fire_absolute_position
	pass
	
func execute():
	owner.element_state_machine.change_state(owner.F_IdleState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "NtoF"
