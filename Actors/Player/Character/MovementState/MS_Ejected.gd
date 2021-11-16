extends State

var time

func _init(o).(o):
	pass

func enter():
	owner.velocity = Vector2(150,-220)
	owner.deceleration = 2
	owner.acceleration = 2
	time = 1
	owner.movement_module.jump_count = 1
	pass
	
func execute():
	time -= owner.get_physics_process_delta_time()
	
	owner.movement_module.move()
	owner.movement_module.jump()
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	
	if time <= 0 :
		owner.movement_state_machine.change_state(owner.MS_FallState.new(owner))
	
	if owner.movement_module.is_on_object:
		owner.movement_state_machine.change_state(owner.MS_IdleState.new(owner))
	
	if owner.get_parent().input_module.is_jump_pressed:
		owner.movement_state_machine.change_state(owner.MS_DoubleJumpState.new(owner))
		
	
	pass

func exit():
	owner.deceleration = 30
	owner.acceleration = 30
	pass

func get_name():
	return "MS_Ejected"
