extends State

var time

func _init(o).(o):
	pass

func enter():
	owner.arrow_sprite.set_visible(false)
	owner.disconnect_absorb_signal()
	owner.character_shadow_sprite.set_visible(false)
	time = 0
	
	owner.set_collision_mask_bit(0,0)
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	owner.bubble_sprite.global_position = lerp(owner.global_position,owner.character.global_position,owner.eject_curve.interpolate(time))
	
	if time > 0.2 :
		owner.set_collision_mask_bit(0,1)
	
	if time >= 0.4 :
		owner.behavior_state_machine.change_state(owner.freeState.new(owner))
		owner.character = null	
	pass

func exit():
	pass

static func get_name():
	return "Eject"
