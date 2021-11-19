extends State

var time

func _init(o).(o):
	pass

func enter():
	time = 0
	owner.movement_module.jump_count = 1
	
	#更改弹出朝向
	if owner.eject_angle <= PI/2 and owner.eject_angle > -PI/2:
		if !owner.collision_module.facing():
			owner.collision_module.change_facing(true)
	else:
		if owner.collision_module.facing():
			owner.collision_module.change_facing(false)
	
	if owner.current_absorb_bubble_global_position != null:
		owner.global_position = owner.current_absorb_bubble_global_position
		owner.current_absorb_bubble_global_position = null
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	owner.velocity = lerp(Vector2(0,0),Vector2(cos(owner.eject_angle), sin(owner.eject_angle)) * 1000,owner.eject_curve.interpolate(time))
	
	if time >= 0.25 :
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
		
	pass

func exit():
	
	pass

static func get_name():
	return "MS_Ejected"
