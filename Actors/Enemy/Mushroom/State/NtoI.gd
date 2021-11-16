extends State

var time
var collision_change_once_flag

func _init(o).(o):
	pass

func enter():
	time = 0
	collision_change_once_flag = true
	owner.can_change_element = false
	owner.element_state = "Ice"
	
	owner.anim_player.play("NtoI_Anim")
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	owner.icefog_particle.process_material.set_emission_sphere_radius(lerp(0,80,owner.icefog_spread_curve.interpolate(time)))
	owner.icefog_sprite.scale = Vector2(lerp(0,1.05,owner.icefog_spread_curve.interpolate(time)),lerp(0,1.05,owner.icefog_spread_curve.interpolate(time)))
	owner.icefog_shape.scale = Vector2(lerp(0,1,owner.icefog_spread_curve.interpolate(time)),lerp(0,1,owner.icefog_spread_curve.interpolate(time)))
	
	if time > 0 and collision_change_once_flag:
		owner.collision_module.change_to_ice_collision()
		collision_change_once_flag = false
	
	owner.emit_icefog_signal()
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return ""
