extends Node

#Animation call function	
func normal_move():
	if owner.is_moving_left:
		owner.apply_central_impulse(Vector2(-100,-50))
	else:
		owner.apply_central_impulse(Vector2(100,-50))

	
