extends State

var time = 0
var absolute_position

func _init(o).(o):
	pass

func enter():
#	owner.collision_module.absorbed_collision()
	owner.velocity = Vector2(0,0)
	absolute_position = owner.global_position
	pass
	
func execute():	
	time += owner.get_physics_process_delta_time()
	
	if time > 0.4:
		owner.collision_module.absorbed_collision()
	
	owner.global_position = lerp(absolute_position,owner.current_absorb_bubble_global_position,owner.absorbed_curve.interpolate(time))
	
	if owner.owner.input_module.is_attack_just_pressed:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
	pass

func exit():
	owner.collision_module.exit_absorbed_collision()
	pass

func get_name():
	return "MS_Absorbed"
