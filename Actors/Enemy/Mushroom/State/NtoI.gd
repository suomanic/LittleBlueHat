extends State

var time

func _init(o).(o):
	pass

func enter():
	time = 0
	owner.collision_module.change_to_ice_collision()
	owner.element_state = "Ice"
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	owner.icefog_particle.process_material.set_emission_sphere_radius(lerp(0,80,owner.icefog_spread_curve.interpolate(time)))
	owner.icefog_sprite.scale = Vector2(lerp(0,1,owner.icefog_spread_curve.interpolate(time)),lerp(0,1,owner.icefog_spread_curve.interpolate(time)))
	
	if time >= 1 :
		owner.state_machine.change_state(owner.I_IdleState.new(owner))
	pass

func exit():
	pass

func get_name():
	return ""
