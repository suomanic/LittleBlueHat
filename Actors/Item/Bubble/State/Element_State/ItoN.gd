extends State

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Normal"
	owner.character_shadow_sprite.set_modulate("ffffff")
	pass
	
func execute():
	owner.element_state_machine.change_state(owner.N_IdleState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "ItoN"
