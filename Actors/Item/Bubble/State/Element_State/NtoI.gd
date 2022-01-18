extends State

var time

func _init(o).(o):
	pass

func enter():
	owner.element_state = "Ice"
	owner.character_shadow_sprite.set_modulate("00a5ff")
	time = 0
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	var distance = owner.normal_absolute_position.distance_to(owner.ice_absolute_position)	
	if distance != 0:
		var offset = min (time / distance * 50,1)
		owner.global_position = lerp(owner.normal_absolute_position,owner.ice_absolute_position,owner.move_curve.interpolate(offset))
	
	
	#owner.element_state_machine.change_state(owner.I_IdleState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "NtoI"
