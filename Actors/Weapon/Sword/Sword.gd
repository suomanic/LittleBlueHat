extends Node2D

func _ready():
	pass

func _physics_process(delta):
	set_as_toplevel(true)
	_move()
	
	if Input.is_action_just_pressed("attack"):
		$AnimationPlayer.play("attack")
	pass

# 追随角色的该武器(self)是否正在换边过程中
var on_changing_side : = Vector2(false, false)

func _move() :
	# 该武器(self)位置和角色位置的目标偏移量
	var target_offset : Vector2
	# 当前鼠标位置和角色位置的偏移量
	var mouse_offset_from_chara : = Vector2(owner.input_module.mouse_global_position - owner.global_position)
	# 当前该武器(self)位置和角色位置的偏移量
	var weapon_offset_from_chara : = Vector2(self.global_position - owner.global_position)

	if(mouse_offset_from_chara.x > 0) :
		scale.x = 1
		target_offset = Vector2(15, -15)
		
		# 如果鼠标、该武器(self)并不在角色所在位置的左右两边，但是该武器(self)并没有到达它应该到的位置，
		# 则认为该武器(self)仍在左右换边过程中，不去动on_changing_side.x
		# 否则，则认为该武器(self)的左右换边过程已经结束，设置on_changing_side_x为false
		if weapon_offset_from_chara.x > (target_offset.x - 0.11) :
			on_changing_side.x = false
		# 如果鼠标、该武器(self)正好在角色所在位置的左右两边，说明要换方向了，设置on_changing_side.x为true
		elif weapon_offset_from_chara.x < 0 :
			on_changing_side.x = true
	else :
		scale.x = -1
		target_offset = Vector2(-15, -15)
		
		# 同上
		if weapon_offset_from_chara.x < (target_offset.x + 0.11) :
			on_changing_side.x = false
		# 同上
		elif weapon_offset_from_chara.x > 0 :
			on_changing_side.x = true
	
	# 线性插值的时候的取值间隔
	var linear_interpolate_scale_rate : = Vector2(0.2, 0.1)
	
	# 如果追随角色的该武器(self)正在左右换边，设置一下非线性动画平滑
	if on_changing_side.x :
		linear_interpolate_scale_rate.x = 0.2
		
		# 追随角色的该武器(self)正在左右换边时，如果鼠标和角色运动方向同向，
		# 为了防止追不上角色，把linear_interpolate_scale_rate.x调大
		if (owner.direction.x > 0 && mouse_offset_from_chara.x > 0) || (owner.direction.x < 0 && mouse_offset_from_chara.x < 0) :
			linear_interpolate_scale_rate.x = 0.5
		
	# 如果追随角色的该武器(self)没有在左右换边的过程中，为了防止追不上角色，
	# 把linear_interpolate_scale_rate.x调大
	else :
		linear_interpolate_scale_rate.x = 0.5
	
	# 水平方向非线性动画
	self.global_position = self.global_position.linear_interpolate(Vector2(owner.global_position.x + target_offset.x, self.global_position.y), linear_interpolate_scale_rate.x)
	# 垂直方向非线性动画
	self.global_position = self.global_position.linear_interpolate(Vector2(self.global_position.x, owner.global_position.y + target_offset.y + mouse_offset_from_chara.y / 20), linear_interpolate_scale_rate.y)
