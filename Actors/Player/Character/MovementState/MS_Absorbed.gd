extends State

var time = 0
var absolute_position

func _init(o).(o):
	pass

func enter():
	owner.velocity = Vector2(0,0)
	absolute_position = owner.global_position
	owner.owner.get_node("Weapon").character_absorbed()
	pass
	
func execute():	
	time += owner.get_physics_process_delta_time()
	
	if time > 0.2:
		owner.collision_module.absorbed_collision()
	
	owner.global_position = lerp(absolute_position,owner.current_absorb_bubble_global_position,owner.absorbed_curve.interpolate(time))
	

func exit():
	
	owner.collision_module.exit_absorbed_collision()
	owner.owner.get_node("Weapon").character_exit_absorbed()
	pass

static func get_name():
	return "MS_Absorbed"
