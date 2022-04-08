extends State

func _init(o).(o):
	pass

func enter():
	print_debug('MS_Hurt enter, hp--')
	owner.hp = owner.hp - 1
#	if  MultiplayerState.get_tree().has_network_peer() \
#	and MultiplayerState.get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
#		# 如果玩家是master节点
#		if owner.is_network_master():
#			print_debug('character_state_ui hp--')
#			owner.get_owner().get_node("LevelCamera").character_state_ui.health_down()
#	else: 
#		print_debug('character_state_ui hp--')
#		owner.get_owner().get_node("LevelCamera").character_state_ui.health_down()
	#print_debug("inininininininininin")
	#print_debug(owner.hp)
	if owner.hp <= 0:
		owner.movement_state_machine.change_state(owner.MS_DieState.new(owner))
		
	owner.movement_module.hurt_move(owner.collision_module.hit_to_direction)
	
	pass
	
func execute():
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	pass

func exit():
	pass

static func get_name():
	return "MS_Hurt"
