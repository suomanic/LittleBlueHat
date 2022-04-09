extends State


var time 

func _init(o).(o):
	pass

func enter():
	if is_instance_valid(owner.player):
		owner.player.absorbed_by_bubble(owner)
	time = 0
	owner.arrow_sprite.set_visible(true)
	owner.character_shadow_sprite.set_visible(true)
	
	owner.arrow_anim_player.play("arrow_appear_anim")
	owner.character_shadow_anim_player.play("appear_anim")
	
	owner.audio_player.play()
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	if is_instance_valid(owner.player):
		if owner.player.movement_state_machine.get_curr_state_name() != owner.player.MS_AbsorbedState.get_name():
			owner.player.absorbed_by_bubble(owner)
		owner.arrow_sprite_movement()
		owner.bubble_sprite.global_position = lerp(owner.global_position,owner.player.global_position,owner.absorb_curve.interpolate(time))
		if owner.player.input_module.is_attack_just_pressed and time > 0.1 :
			owner.eject()


func exit():
	pass

static func get_name():
	return "Occupied"
