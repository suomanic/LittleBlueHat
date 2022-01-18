extends State

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Ice"
	owner.character_shadow_sprite.set_modulate("00a5ff")
	pass
	
func execute():
	owner.element_state_machine.change_state(owner.I_IdleState.new(owner))
	owner.global_position
	
	pass

func exit():
	pass

static func get_name():
	return "NtoI"
