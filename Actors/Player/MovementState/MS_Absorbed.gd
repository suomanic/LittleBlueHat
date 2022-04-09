extends State

var time = 0
var absolute_position

func _init(o).(o):
	pass

func enter():
	owner.velocity = Vector2(0,0)
	absolute_position = owner.global_position
	owner.get_node("Weapon").character_absorbed()
	owner.collision_module.absorbed_collision()
	pass
	
func execute():	
	time += owner.get_physics_process_delta_time()
	
	if time > 0.2:
		owner.anim_sprite.set_visible(false)
	
	if is_instance_valid(owner.current_absorb_bubble):
		if absolute_position!=null:
			owner.global_position = lerp(absolute_position,owner.current_absorb_bubble.global_position,owner.absorbed_curve.interpolate(time))
#		if owner.current_absorb_bubble.behavior_state_machine.get_curr_state_name() == owner.current_absorb_bubble.freeState.get_name():
#			pass

func exit():
	owner.get_node("Weapon").character_exit_absorbed()
	pass

static func get_name():
	return "MS_Absorbed"
