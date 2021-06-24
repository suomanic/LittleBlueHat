extends Position2D


func _process(delta):
	global_position = global_position.linear_interpolate(owner.global_position,0.1)
