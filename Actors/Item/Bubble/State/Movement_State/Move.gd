extends State

var time = 0
var offset
var current_absolute_position

func _init(o).(o):
	pass

func enter():
	time = 0
	offset = 0
	current_absolute_position = owner.global_position
	owner.can_change_element = false
	pass
	
func execute():
	owner.label3.text = String(offset)
	
	time += owner.get_physics_process_delta_time()
	
	var distance = current_absolute_position.distance_to(owner.move_target)	
	if distance != 0:
		offset = min (time / distance * owner.move_speed,1)
	owner.global_position = lerp(owner.global_position,owner.move_target,owner.move_curve.interpolate(offset))
	pass
	
	if offset >= 1:
		owner.movement_state_machine.change_state(owner.idleState.new(owner))

func exit():
	pass

static func get_name():
	return "Move"
