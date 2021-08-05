extends Node2D

class_name Weapon
# Called when the node enters the scene tree for the first time.

onready var weapon_data :={
	F_sword = preload("res://Actors/Player/Weapon/Sword/FireSword.tscn"),
	I_sword = preload("res://Actors/Player/Weapon/Sword/IceSword.tscn"),
	F_orb = preload("res://Actors/Player/Weapon/MagicOrb/FireMagicOrb.tscn"),
	I_orb = preload("res://Actors/Player/Weapon/MagicOrb/IceMagicOrb.tscn")
}

func _ready():
	owner=get_parent()
	pass # Replace with function body.
	
func _physics_process(delta):
	if owner.input_module.is_weapon1_just_pressed:
		change_weapon("F_sword")
	elif owner.input_module.is_weapon2_just_pressed:
		change_weapon("I_sword")
	elif owner.input_module.is_weapon3_just_pressed:
		change_weapon("F_orb")
	elif owner.input_module.is_weapon4_just_pressed:
		change_weapon("I_orb")
	
# 追随角色的该武器(self)是否正在换边过程中
var on_changing_side : = Vector2(false, false)

func follow_player():
	# 该武器(self)位置和角色位置的固定偏移量，其中fix_offset.x为绝对值
	var fix_offset :=Vector2(13, -10)
	# 该武器(self)位置和角色位置的目标偏移量
	var target_offset : = Vector2(0, 0)
	# 当前鼠标位置和角色位置的偏移量
	var mouse_offset_from_chara : = Vector2(owner.input_module.mouse_global_position -  owner.character.global_position)
	# 当前该武器(self)位置和角色位置的偏移量
	var weapon_offset_from_chara : = Vector2(global_position - owner.character.global_position)
	
	# 武器y坐标绝对值的最大值（不包括固定偏移量）
	var max_abs_y : = 16
	# 操控武器y坐标（不包括固定偏移量）的鼠标y坐标绝对值 和 武器y坐标（不包括固定偏移量）的比值
	# 用人话来说，就是鼠标操控范围和武器移动范围的比值，或者称之为放大倍数
	var control_y_ratio : = 2
	
	# 设定target_offset.y
	# 先判断鼠标在角色的上方还是下方，分别处理
	if(mouse_offset_from_chara.y > 0) :
		# 如果鼠标移动到超过鼠标移动范围的区域，则直接设置武器y坐标的绝对值为其最大值（然后还得加上固定偏移量）
		if mouse_offset_from_chara.y > max_abs_y * control_y_ratio :
			target_offset.y = fix_offset.y + max_abs_y
		# 如果鼠标的y坐标偏移量没超过范围，则设置武器y坐标的绝对值为 鼠标的y坐标偏移量/放大倍数（然后还得加上固定偏移量）
		else :
			target_offset.y = fix_offset.y + mouse_offset_from_chara.y / 2
	else :
		# 同上
		if mouse_offset_from_chara.y < - max_abs_y * control_y_ratio :
			target_offset.y = fix_offset.y - max_abs_y
		# 同上
		else :
			target_offset.y = fix_offset.y + mouse_offset_from_chara.y / 2
	
	# 弧线的参数，为椭圆，满足y=asinθ，x=bcosθ（y需要先减去固定偏移量）
	# 注意，ellipse_a不能小于max_abs_y
	var ellipse_a = max_abs_y
	var ellipse_b = ellipse_a / 4
	# θ=arcsin(y/a)（y需要先减去固定偏移量）
	var ellipse_theta = asin((target_offset.y - fix_offset.y) / ellipse_a)
	
	# 设定target_offset.x
	# 先判断鼠标在角色的左边还是右边，分别处理
	if(mouse_offset_from_chara.x > 0) :
		scale.x = 1
		fix_offset.x = +fix_offset.x # 向右偏移
		# x=bcosθ（x需要再加上固定偏移量）
		target_offset.x = fix_offset.x + ellipse_b * cos(ellipse_theta)
		
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
		fix_offset.x = -fix_offset.x # 向左偏移
		# x=bcosθ（x需要再加上固定偏移量）
		target_offset.x = fix_offset.x - ellipse_b * cos(ellipse_theta)
		
		# 同上
		if weapon_offset_from_chara.x < (target_offset.x + 0.11) :
			on_changing_side.x = false
		# 同上
		elif weapon_offset_from_chara.x > 0 :
			on_changing_side.x = true
	
	# 线性插值的时候的取值间隔
	var linear_interpolate_scale_rate : = Vector2(0.2, 0.35)
	
	# 如果追随角色的该武器(self)正在左右换边，设置一下非线性动画平滑
	if on_changing_side.x :
		linear_interpolate_scale_rate.x = 0.25
		
		# 追随角色的该武器(self)正在左右换边时，如果鼠标和角色运动方向同向，
		# 为了防止追不上角色，把linear_interpolate_scale_rate.x调大
		if (owner.input_module.get_direction().x > 0 && mouse_offset_from_chara.x > 0) || (owner.input_module.get_direction().x < 0 && mouse_offset_from_chara.x < 0) :
			linear_interpolate_scale_rate.x = 0.5
		
	# 如果追随角色的该武器(self)没有在左右换边的过程中，为了防止追不上角色，
	# 把linear_interpolate_scale_rate.x调大
	else :
		linear_interpolate_scale_rate.x = 0.5
	
	# 水平方向非线性动画
	global_position = global_position.linear_interpolate(Vector2(owner.character.global_position.x + target_offset.x, self.global_position.y), linear_interpolate_scale_rate.x)
	# 垂直方向非线性动画
	global_position = global_position.linear_interpolate(Vector2(global_position.x, owner.character.global_position.y + target_offset.y), linear_interpolate_scale_rate.y)

func change_weapon(weapon_type:String):
	for i in self.get_children():
		i.queue_free()
		
	match weapon_type:
		"F_sword":
			add_child(weapon_data.F_sword.instance())
		"I_sword":
			add_child(weapon_data.I_sword.instance())
		"F_orb":
			add_child(weapon_data.F_orb.instance())
		"I_orb":
			add_child(weapon_data.I_orb.instance())
