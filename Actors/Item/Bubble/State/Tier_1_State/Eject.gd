extends State

var time

func _init(o).(o):
	pass

func enter():
	owner.arrow_sprite.set_visible(false)
	owner.disconnect_absorb_signal()
	time = 0
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	owner.bubble_sprite.global_position = lerp(owner.absolute_position,owner.character.global_position,owner.eject_curve.interpolate(time))
	
	if time >= 0.4 :
		owner.state_machine.change_state(owner.freeState.new(owner))
		owner.character = null	
	pass

func exit():
	pass

static func get_name():
	return "Eject"
