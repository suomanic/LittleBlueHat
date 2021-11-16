extends State

var time

func _init(o).(o):
	pass

func enter():
	time = 0
	pass
	
func execute():
	time += owner.get_physics_process_delta_time()
	
	if time > 0.3:
		owner.get_child(0).sprite.set_visible(false)
	
	owner.global_position = lerp(owner.absolute_position,owner.character.current_absorb_bubble_global_position - Vector2(0,12),owner.absorbed_position_curve.interpolate(time))
	owner.get_child(0).scale = lerp(Vector2(1,1),Vector2(0,0),owner.absorbed_scale_curve.interpolate(time))
	pass

func exit():
	pass

static func get_name():
	return ""
