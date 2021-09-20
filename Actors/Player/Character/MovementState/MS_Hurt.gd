extends State

func _init(o).(o):
	pass

func enter():
	owner.hp = owner.hp - 1
	print_debug("inininininininininin")
	print_debug(owner.hp)
	if owner.hp <= 0:
		owner.movement_state_machine.change_state(owner.MS_DieState.new(owner))
		
	owner.movement_module.hurt_move(owner.collision_module.will_go_left)
	
	pass
	
func execute():
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	pass

func exit():
	pass

func get_name():
	return "MS_Hurt"
