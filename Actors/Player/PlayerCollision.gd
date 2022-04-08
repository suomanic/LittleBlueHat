extends Node

var is_bounced := false
# 被撞飞的朝向
var hit_to_direction: bool
var can_be_squished := true

# 储存上一次同步的人物朝向信息
onready var last_sync_facing: bool

# 定时强行同步额外信息的计时器（需要定时同步防止因为丢包造成问题）
var rpc_timing_sync_facing_timer:Timer

func _ready():
	rpc_timing_sync_facing_timer = Timer.new()
	rpc_timing_sync_facing_timer.one_shot = false
	rpc_timing_sync_facing_timer.wait_time = 1
	rpc_timing_sync_facing_timer.connect("timeout", self, "sync_facing")
	rpc_timing_sync_facing_timer.autostart = true
func _physics_process(delta):
	if owner.movement_module.is_on_object:
		owner.squish_collision.set_disabled(false)
	else :
		owner.squish_collision.set_disabled(true)

# 更新并获取朝向信息，朝右则返回true
# the boolean means is character facing right,true means right
func facing() -> bool:
	# 如果处于联机模式下且自己不是master节点
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and !is_network_master():
		return owner.anim_sprite.scale.x >= 0
	
	var new_facing:bool = owner.anim_sprite.scale.x >= 0
	if owner.input_module.get_direction().x > 0 :
		owner.walk_particles.scale.x = 1
		owner.walk_particles.position = Vector2(-5,12)
		change_facing(true)
		new_facing = true 
	elif owner.input_module.get_direction().x < 0 :
		owner.walk_particles.scale.x = -1
		owner.walk_particles.position = Vector2(5,12)
		change_facing(false)
		new_facing = false 
	
	sync_facing(new_facing)
	
	return new_facing

func sync_facing(new_facing = null):
	# 如果处于联机模式下且自己是master节点
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and is_network_master():
		if new_facing == null:
			new_facing = facing()
		if new_facing != last_sync_facing:
			last_sync_facing = new_facing
			rpc_unreliable("change_facing", new_facing)

# 更新朝向，true表示向右
puppet func change_facing(new_facing: bool):
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and !is_network_master():
		print_debug("change facing to ", "right" if new_facing else "left")
	if new_facing == true :
		owner.anim_sprite.scale.x = 1
	elif new_facing == false :
		owner.anim_sprite.scale.x = -1

func die_collision_change():
	owner.standing_collision.set_disabled(true) 
	owner.trigger_collision.set_disabled(true)
	owner.squish_collision.set_disabled(true)
	pass


func _on_enemy_area_entered(area: Area2D):
	is_bounced = true
	var body = area.get_owner()
	
	if body == null:
		return
	if body.name.begins_with("Slime"):
		if body.get("element_state") == "Normal" :
			pass
		elif body.get("element_state") == "Fire" :
			if body.global_position.x - owner.global_position.x > 0 :
				hit_to_direction = false
			else:
				hit_to_direction = true
			
			if owner.hp > 0: 
				owner.movement_state_machine.change_state(owner.MS_HurtState.new(owner))
				owner.anim_state_machine.change_state(owner.AS_HurtState.new(owner))
#				if get_tree().has_network_peer() \
#					and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
#						if EntitySyncManager.is_network_master():
#							owner.hurt()
#							EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'call_func', owner.get_path(), {'hurt':[hit_to_direction]})
#				else: owner.hurt()

	pass # Replace with function body.


func _on_mushroom_area_entered(area: Area2D):
	if area.is_in_group("Mushroom"):
		
		if area.element_state == "Fire":
			owner.movement_module.bounce()
			var audio_player = AudioStreamPlayer2D.new()
			audio_player.stream = load("res://Assets/Audio/spring_detect.wav")
			owner.add_child(audio_player)
			audio_player.play()
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
			hit_to_direction = false
		else:
			hit_to_direction = true
			
		if owner.hp > 0 and can_be_squished: 
			owner.anim_state_machine.change_state(owner.AS_HurtState.new(owner))
			owner.movement_state_machine.change_state(owner.MS_HurtState.new(owner))
			can_be_squished = false
		
#			if get_tree().has_network_peer() \
#			and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
#				if EntitySyncManager.is_network_master():
#					owner.squish_hit_hurt()
#					EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'call_func', owner.get_path(), {'squish_hit_hurt':[hit_to_direction]})
#			else: owner.squish_hit_hurt()


func _on_SDM_Timer_timeout():
	owner.set_collision_mask(00000000000000100011)
	owner.hurt_move_timer.stop()
	can_be_squished = true
	pass # Replace with function body.


func absorbed_collision():
	owner.trigger_collision.set_deferred("disabled",true)
	owner.squish_collision.set_deferred("disabled",true)
	owner.trigger.set_collision_layer_bit(0,false)
	owner.set_collision_layer_bit(0,false)
	pass
	
func exit_absorbed_collision():
	owner.anim_sprite.set_visible(true)
	owner.trigger_collision.set_deferred("disabled",false)
	owner.squish_collision.set_deferred("disabled",false)
	owner.trigger.set_collision_layer_bit(0,true)
	owner.set_collision_layer_bit(0,true)
	pass

func invincible_anim_start():
	owner.trigger_collision.set_disabled(true)
	
func invincible_anim_end():
	owner.trigger_collision.set_disabled(false)	
