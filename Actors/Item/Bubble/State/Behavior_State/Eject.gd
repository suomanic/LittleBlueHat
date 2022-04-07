extends State

var time

# signal eject_signal

func _init(o).(o):
	pass

func enter():
	if is_instance_valid(owner.player):
		owner.player.ejected_from_bubble(owner.eject_angle,owner)
	owner.arrow_sprite.set_visible(false)
	owner.character_shadow_sprite.set_visible(false)
	time = 0
	
	owner.set_collision_mask_bit(0,0)
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	if is_instance_valid(owner.player):
		owner.bubble_sprite.global_position = lerp(owner.global_position,owner.player.global_position,owner.eject_curve.interpolate(time))
	
	if time > 0.2 :
		owner.set_collision_mask_bit(0,1)
	
	if time >= 0.4 :
		owner.behavior_state_machine.change_state(owner.freeState.new(owner))


func exit():
	pass

static func get_name():
	return "Eject"
