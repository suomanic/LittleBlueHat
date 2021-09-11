extends Node

var is_bounced := false

func _physics_process(delta):
	if owner.is_on_floor():
		owner.squish_collision.set_disabled(false)

func _on_enemy_area_entered(area: Area2D):
	# 部分area的owner本身目前没有element_state这个变量（比如剑），会卡死游戏
	# 所以用get方法而不是直接引用，get不到会返回null而不是卡死
	is_bounced = true
			
	if area.get_owner().get("element_state") == "Normal" :
		pass
	elif area.owner.get("element_state") == "Ice" :
		pass

	pass # Replace with function body.


func _on_mushroom_area_entered(area: Area2D):
	if area.is_in_group("Mushroom"):
		print_debug("mogu mogu")
		if area.element_state == "Fire":
			owner.movement_module.bounce()
	pass # Replace with function body.


func _on_SquishHitBox_body_entered(body):
	if body.is_in_group("Slime") and body.can_cause_squish_damage :
		
		owner.SDM_Timer.set_wait_time(0.1)
		owner.SDM_Timer.start()
		owner.set_collision_mask(00000000000000000011)
		owner.squish_collision.set_disabled(true)
		
		
		#被砸击退
		var will_go_left : bool
		
		if body.global_position.x - owner.global_position.x > 0 :
			will_go_left = false
		else:
			will_go_left = true
			
		owner.movement_module.squish_damage_move(will_go_left)
		pass


func _on_SDM_Timer_timeout():
	owner.set_collision_mask(00000000000000100011)
	owner.SDM_Timer.stop()
	pass # Replace with function body.
