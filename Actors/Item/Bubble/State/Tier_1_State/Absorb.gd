extends State

signal eject_signal

var time 

func _init(o).(o):
	pass

func enter():
	time = 0
	
	owner.arrow_sprite.set_visible(true)
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	owner.arrow_sprite_movement()
	
	owner.bubble_sprite.global_position = lerp(owner.absolute_position,owner.character.global_position,owner.absorb_curve.interpolate(time))
	
	if owner.character.get_parent().input_module.is_attack_just_pressed:
		connect("eject_signal",owner.character,"ejected_from_bubble")
		emit_signal("eject_signal",owner.eject_angle)
		owner.state_machine.change_state(owner.ejectState.new(owner))
	
	if time >= 0.5:
		owner.state_machine.change_state(owner.occupiedState.new(owner))
	
	pass

func exit():
	pass

static func get_name():
	return "Absorb"
