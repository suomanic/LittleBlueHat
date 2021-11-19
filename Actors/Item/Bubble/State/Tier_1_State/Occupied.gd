extends State

signal eject_signal

var time 

func _init(o).(o):
	pass

func enter():
	time = 0
	
	owner.arrow_sprite.set_visible(true)
	owner.character_shadow_sprite.set_visible(true)
	
	owner.arrow_anim_player.play("arrow_appear_anim")
	owner.character_shadow_anim_player.play("appear_anim")
	
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	owner.arrow_sprite_movement()
	
	owner.bubble_sprite.global_position = lerp(owner.absolute_position,owner.character.global_position,owner.absorb_curve.interpolate(time))
	
	if owner.character.get_parent().input_module.is_attack_just_pressed and time > 0.1 :
		connect("eject_signal",owner.character,"ejected_from_bubble")
		emit_signal("eject_signal",owner.eject_angle)
		owner.state_machine.change_state(owner.ejectState.new(owner))
	
	
	pass

func exit():
	pass

static func get_name():
	return "Occupied"
