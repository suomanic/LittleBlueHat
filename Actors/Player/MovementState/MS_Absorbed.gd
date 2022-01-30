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
	
	owner.global_position = lerp(absolute_position,owner.current_absorb_bubble.global_position,owner.absorbed_curve.interpolate(time))
	

func exit():
	owner.get_node("Weapon").character_exit_absorbed()
	pass

static func get_name():
	return "MS_Absorbed"
