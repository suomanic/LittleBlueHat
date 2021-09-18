extends Node

var is_bounced := false
var will_go_left
var can_be_squished := true

#false means facing right
var is_facing_left : bool
var pre_facing = false 

func _physics_process(delta):
	if owner.movement_module.is_on_object:
		owner.squish_collision.set_disabled(false)
	else :
		owner.squish_collision.set_disabled(true)

func facing() -> bool : #the boolean means is character facing left,true means left
	if owner.owner.input_module.get_direction().x > 0 :
		owner.anim_sprite.scale.x = 1
		owner.die_sprite.scale.x = -1
		pre_facing = false
		return false
	elif owner.owner.input_module.get_direction().x < 0 :
		owner.anim_sprite.scale.x = -1
		owner.die_sprite.scale.x = 1
		pre_facing = true
		return true
	else:
		return pre_facing

func _on_enemy_area_entered(area: Area2D):
	# 部分area的owner本身目前没有element_state这个变量（比如剑），会卡死游戏
	# 所以用get方法而不是直接引用，get不到会返回null而不是卡死
	is_bounced = true
	var body
	
	if area.get_owner() != null:
		body = area.get_owner()
	if body.name.begins_with("Slime"):
		if body.get("element_state") == "Normal" :
			pass
		elif body.get("element_state") == "Fire" :
			if body.global_position.x - owner.global_position.x > 0 :
				will_go_left = false
			else:
				will_go_left = true
			
			if owner.hp > 0: 
				owner.movement_state_machine.change_state(owner.MS_HurtState.new(owner))
				owner.anim_state_machine.change_state(owner.AS_HurtState.new(owner))

	pass # Replace with function body.


func _on_mushroom_area_entered(area: Area2D):
	if area.is_in_group("Mushroom"):
		if area.element_state == "Fire":
			owner.movement_module.bounce()
	else:
		pass
	pass # Replace with function body.


func _on_SquishHitBox_body_entered(body):
	if body.is_in_group("Slime") and body.can_cause_squish_damage :
		
		owner.hurt_move_timer.set_wait_time(0.1)
		owner.hurt_move_timer.start()
		owner.set_collision_mask(00000000000000000011)
		
		#被砸击退
		if body.global_position.x - owner.global_position.x > 0 :
			will_go_left = false
		else:
			will_go_left = true
			
		if owner.hp > 0 and can_be_squished: 
			owner.anim_state_machine.change_state(owner.AS_HurtState.new(owner))
			owner.movement_state_machine.change_state(owner.MS_HurtState.new(owner))
			can_be_squished = false
		pass

func _on_SDM_Timer_timeout():
	owner.set_collision_mask(00000000000000100011)
	owner.hurt_move_timer.stop()
	can_be_squished = true
	pass # Replace with function body.


func invincible_anim_start():
	owner.trigger_collision.set_disabled(true)
	
func invincible_anim_end():
	owner.trigger_collision.set_disabled(false)	
