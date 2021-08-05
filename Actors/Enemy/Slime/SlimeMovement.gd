extends Node

#Animation call function	
func normal_move():
	owner.set_gravity_scale(6)
	if owner.is_moving_left:
		owner.apply_central_impulse(Vector2(-100,-50))
	else:       
		owner.apply_central_impulse(Vector2(100,-50))
	
func fire_move():
	owner.set_gravity_scale(12)
	if owner.is_moving_left:
		owner.apply_central_impulse(Vector2(-100,-300))
	else:       
		owner.apply_central_impulse(Vector2(100,-300))
		

func move_finish():
	owner.is_moving_finished = true
	
func move_start():
	owner.is_moving_finished = false
