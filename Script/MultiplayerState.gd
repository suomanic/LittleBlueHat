extends Node

# 定义初始加载的游戏场景
const initial_scene := 'res://Levels/InitialLevel/InitialLevel.tscn'

var player_info_template: Dictionary = {'custom_name':'','type':''}

# 基本属性：联网id，名字，类型
var my_id : int = 0
var my_player_info: Dictionary = player_info_template.duplicate()
var remote_id : int = 0
var remote_player_info: Dictionary = player_info_template.duplicate()

var my_player_instance: Node2D = null
var remote_player_instance: Node2D = null

#var isMyPlayerDone:bool = false
#var isRemotePlayerDone:bool = false


# 这里5个信号都是 Godot High-level multiplayer API 自带信号
func _ready() -> void:
	self.get_tree().connect('network_peer_connected', self, '_on_network_peer_connected')
	self.get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected')
	self.get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	self.get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	self.get_tree().connect('connection_failed', self, '_on_connection_failed')
	for c in get_tree().current_scene.get_children():
		if c.name.begins_with("Player"):
			my_player_instance = c


# 每当和终端连接成功（无论谁是发起方），就会调用该方法，不论自身是服务端还是客户端
# ● network_peer_connected(id: int)
# 当这个SceneTree的network_peer与一个新的对等体连接时发出。
# ID是新对等体的对等体ID。当其他客户端连接到同一个服务器时，客户端会得到通知。
# 当连接到一个服务器时，客户端也会收到该服务器的这个信号（ID为1）。
func _on_network_peer_connected(rpc_remote_id : int) -> void:
	print_debug('player peer ', rpc_remote_id, ' connected')
	
	self.get_tree().refuse_new_network_connections = true
	
	# 通过 rpc_id 将自己的信息远程发送给对方进行注册
	var my_scene_info = {'scene_path_or_name': get_tree().current_scene.name}
	rpc_id(rpc_remote_id, 'register_remote_info', var2str(my_player_info), var2str(my_scene_info))


# 每当有终端断开链接，就会调用该方法，不论自身是服务端还是客户端
# ● network_peer_disconnected(id: int)
# 每当此 SceneTree 的 network_peer 与对等方断开连接时发出。
# 当其他客户端与同一服务器断开连接时，客户端会收到通知。
func _on_network_peer_disconnected(rpc_remote_id : int) -> void:
	get_tree().set_pause(true)
	print_debug('player peer ', rpc_remote_id, ' disconnected')
	# 如果是服务端，删除对方并重置远程玩家相关的变量，重新等待连接
	if self.get_tree().is_network_server():
		remote_id = 0
		remote_player_info = player_info_template.duplicate()
#		isRemotePlayerDone = false
		var world:Node2D = get_tree().current_scene
		if is_instance_valid(world) && is_instance_valid(remote_player_instance):
			if world.is_a_parent_of(remote_player_instance):
				world.remove_child(remote_player_instance)
			remote_player_instance.queue_free()
			remote_player_instance = null
		self.get_tree().refuse_new_network_connections = false
	else:
		# 因为是双人游戏，所以不会是客户端，这里的处理没啥必要，pass
		pass
	get_tree().set_pause(false)


# 连接到服务端成功，仅当自身是客户端时调用
# ● connected_to_server()
# 当此SceneTree的network_peer成功连接到一个服务器时发出。只在客户端发出。
func _on_connected_to_server() -> void:
	print_debug('connected to server')
	pass


# 与服务器断开连接(一般是被t了)，仅当自身是客户端时调用
# ● server_disconnected()
# 当此 SceneTree 的 network_peer 与服务器断开连接时发出。仅在客户端上发出。
func _on_server_disconnected() -> void:
	print_debug('lost connection to server')
	recreate_scene(initial_scene)
	pass


# 与服务器连接失败，仅当自身是客户端时调用
# ● connection_failed()
# 每当此 SceneTree 的 network_peer 无法与服务器建立连接时发出。仅在客户端上发出。
func _on_connection_failed() -> void:
	print_debug('failed to connect to server')
	recreate_scene(initial_scene)
	pass


# 远程方法，处理来自其他玩家的调用，添加其他玩家的信息到 remote_player_info
# 注意，这个方法实际是其他玩家调用（发送），或者说你通过该方法接收到了来自其他玩家的信息
remote func register_remote_info(rpc_remote_player_info_str: String, rpc_remote_scene_info_str: String):
	var rpc_remote_id = self.get_tree().get_rpc_sender_id()
	var success = false
	get_tree().set_pause(true)
	# 如果我方没被连接过，则注册新玩家id和信息
	if(remote_id == 0):
		remote_id = rpc_remote_id
		var temp_remote_player_info: Dictionary = str2var(rpc_remote_player_info_str)
		if temp_remote_player_info != null && temp_remote_player_info.has_all(['custom_name', 'type']):
			remote_player_info = temp_remote_player_info
			var temp_remote_scene_info: Dictionary = str2var(rpc_remote_scene_info_str)
			# 如果是服务端，则不需要加载远程地图，直接加载玩家
			if get_tree().is_network_server():
				# 加载本地玩家，不覆盖
				if load_player(my_id, false):
					# 加载远程玩家，覆盖
					success = load_player(remote_id, true)
			# 如果不是服务端，则需要先加载远程地图，成功后再加载玩家
			else:
				#先将自己从当前场景中提出
				var tmp_curr_scene = get_tree().current_scene
				if tmp_curr_scene.is_a_parent_of(my_player_instance):
					tmp_curr_scene.remove_child(my_player_instance)
				#加载世界，覆盖
				if load_scene(temp_remote_scene_info['scene_path_or_name'], true):
					# 删除场景树内的初始玩家
					tmp_curr_scene = get_tree().current_scene
					var tempPlayer:Node2D = null
					for c in tmp_curr_scene.get_children():
						if c.name.begins_with("Player"):
							tempPlayer = c
							break
					if is_instance_valid(tempPlayer):
						tmp_curr_scene.remove_child(tempPlayer)
						tempPlayer.queue_free()
						tempPlayer = null
					# 加载本地玩家，不覆盖
					if load_player(my_id, false):
						# 加载远程玩家，覆盖
						success = load_player(remote_id, true)
	get_tree().set_pause(false)
	# 如果加载远程地图或玩家失败，则关闭对该远程玩家的连接
	if(!success):
		print_debug('loading remote player failed')
		if get_tree().is_network_server():
			get_tree().network_peer.disconnect_peer(rpc_remote_id)
		else:
			get_tree().network_peer.close_connection()
			#客户端关闭远程连接不会发出信号，需要手动发
			get_tree().emit_signal("server_disconnected")


# 加载场景
# force_override: 如果当前场景和目标场景的节点名相同，是否覆盖（删除并重新创建）
# 注意，如果覆盖了原场景，原场景中的玩家instance也会一起被删除，如果需要保留则应该提前将其从场景树中remove
func load_scene(scene_path_or_name: String, force_override: bool) -> bool:
	# 检测路径或名字是否可用
	var load_by_path = load(scene_path_or_name)
	var load_by_name_type1 = load("res://Levels/"+scene_path_or_name+".tscn")
	var load_by_name_type2 = load("res://Levels/"+scene_path_or_name+"/"+scene_path_or_name+".tscn")
	var world:Node2D
	if is_instance_valid(load_by_path):
		world = load_by_path.instance()
	elif is_instance_valid(load_by_name_type1):
		world = load_by_name_type1.instance()
	elif is_instance_valid(load_by_name_type2):
		world = load_by_name_type2.instance()
	else:
		return false
	
	var curr_world:Node2D = get_tree().current_scene
	if is_instance_valid(curr_world):
		# 如果没有要求强制覆盖，且原世界和现在的一样，则不加载直接返回
		if !force_override && world.name == curr_world.name:
			return true
			
		get_tree().root.remove_child(curr_world)
		curr_world.queue_free()
		curr_world = null
	
	# 加载世界
	get_tree().root.add_child(world)
	get_tree().current_scene = world
	return true


# 加载玩家实体
# target_player_id: 玩家id，用于计算玩家节点名称、检测玩家类型为本地或者远程
# force_override: 如果已经存在相同节点名的同网络类型玩家（无论是否在场景内），是否覆盖（即删除并重新创建）。
# span_position: 出生点，如果不设置则会出生在当前场景内的传送阵内，如果找不到则随机挑选一个玩家实体的位置。如果都没有，则会出生在(0,0)
func load_player(target_player_id:int, force_override: bool, span_position = null) -> bool:
	var world:Node2D = get_tree().current_scene
	var target_player_node_name: String = "Player" + str(target_player_id)
	var is_remote: bool
	
	# --- 异常检测+本地/远程玩家类型检测 ---
	if target_player_id == 0:
		return false # id不能为初始值
	
	if target_player_id == my_id:
		is_remote = false
	elif target_player_id == remote_id:
		is_remote = true
	else:
		return false # 不能加载没有注册过信息的玩家
	
	if !is_instance_valid(world):
		return false # 不能在加载场景前创建角色
	# --- 检测结束 ---
	
	# 计算出生位置
	if typeof(span_position) != TYPE_VECTOR2:
		var teleport = world.find_node("Teleport", false)
		var already_player = world.find_node("Player*", false)
		if is_instance_valid(teleport):
			span_position = teleport.global_position
		elif is_instance_valid(already_player):
			span_position = already_player.global_position
		else:
			span_position = Vector2(0, 0)
	# 加载远程玩家
	if is_remote:
		# 如果强制覆盖
		if force_override:
			# 强制覆盖的情况下如果存在对应玩家则删除
			if is_instance_valid(remote_player_instance):
				if world.is_a_parent_of(remote_player_instance):
					world.remove_child(remote_player_instance)
				remote_player_instance.queue_free()
				remote_player_instance = null
			remote_player_instance = load('res://Actors/Player/Player.tscn').instance()
			remote_player_instance.set_name(target_player_node_name)
			world.add_child(remote_player_instance)
			remote_player_instance.global_position = span_position
		# 如果不强制覆盖
		else:
			# 不覆盖的情况下存在相同节点名的玩家则保留
			if is_instance_valid(remote_player_instance) \
			&& remote_player_instance.name == target_player_node_name:
				# 如果该相同节点名的玩家已经在当前场景中了，则重设位置
				if world.is_a_parent_of(remote_player_instance):
					remote_player_instance.global_position = span_position
				# 如果该相同节点名的玩家不在当前场景中，则加进去
				else:
					world.add_child(remote_player_instance)
					remote_player_instance.global_position = span_position
			else:
				# 如果此时还存在对应网络类型的玩家，但是节点名不一样，则判断为异常产生的玩家，清除
				if is_instance_valid(remote_player_instance):
					if world.is_a_parent_of(remote_player_instance):
						world.remove_child(remote_player_instance)
					remote_player_instance.queue_free()
					remote_player_instance = null
				remote_player_instance = load('res://Actors/Player/Player.tscn').instance()
				remote_player_instance.set_name(target_player_node_name)
				world.add_child(remote_player_instance)
				remote_player_instance.global_position = span_position
		remote_player_instance.set_network_master(remote_id)
	# 加载本地玩家
	else:
		# 如果强制覆盖
		if force_override:
			# 强制覆盖的情况下如果存在对应玩家则删除
			if is_instance_valid(my_player_instance):
				if world.is_a_parent_of(my_player_instance):
					world.remove_child(my_player_instance)
				my_player_instance.queue_free()
				my_player_instance = null
			my_player_instance = load('res://Actors/Player/Player.tscn').instance()
			my_player_instance.set_name(target_player_node_name)
			world.add_child(my_player_instance)
			my_player_instance.global_position = span_position
		# 如果不强制覆盖
		else:
			# 不覆盖的情况下存在相同节点名的玩家则保留
			if is_instance_valid(my_player_instance) \
			&& my_player_instance.name == target_player_node_name:
				# 如果该相同节点名的玩家已经在当前场景中了，则啥都不干
				if world.is_a_parent_of(my_player_instance):
					my_player_instance.global_position = span_position
				# 如果该相同节点名的玩家不在当前场景中，则加进去
				else:
					world.add_child(my_player_instance)
					my_player_instance.global_position = span_position
			else:
				# 如果此时还存在对应网络类型的玩家，但是节点名不一样，则判断为异常产生的玩家，清除
				if is_instance_valid(my_player_instance):
					if world.is_a_parent_of(my_player_instance):
						world.remove_child(my_player_instance)
					my_player_instance.queue_free()
					my_player_instance = null
				my_player_instance = load('res://Actors/Player/Player.tscn').instance()
				my_player_instance.set_name(target_player_node_name)
				world.add_child(my_player_instance)
				my_player_instance.global_position = span_position
		my_player_instance.set_network_master(my_id)
	return true


# 更新玩家信息
remote func update_player_info(rpc_remote_player_info_str: String):
	var rpc_remote_id = self.get_tree().get_rpc_sender_id()
	# 如果本地储存的远程id和收到的远程id是同一id，则可以更新信息，设置info
	if(remote_id == rpc_remote_id):
		var temp_remote_player_info: Dictionary = str2var(rpc_remote_player_info_str)
		if temp_remote_player_info != null && temp_remote_player_info.has_all(['custom_name', 'type']):
			remote_player_info = temp_remote_player_info
# 更新地图信息
remote func update_scene_info(rpc_remote_scene_info_str: String):
	pass

# 创建新游戏
func recreate_scene(scene_path: String = initial_scene) -> bool:
	get_tree().set_pause(true)
	
	# 初始化
	reset_network()
	var world:Node2D = get_tree().current_scene
	if is_instance_valid(world):
		get_tree().root.remove_child(world)
		world.queue_free()
	
	world = null
	my_player_instance = null
	remote_player_instance = null
	
	# 加载世界
	world = load(scene_path).instance()
	get_tree().root.add_child(world)
	get_tree().current_scene = world
	
	var global_span_position = Vector2(0, 20)
	var tempPlayer:Node2D = null
	for c in world.get_children():
		if c.name.begins_with("Player"):
			tempPlayer = c
			break
	if is_instance_valid(tempPlayer):
		global_span_position = tempPlayer.global_position
		world.remove_child(tempPlayer)
		tempPlayer.queue_free()
		tempPlayer = null
	
	# 加载玩家（单人）
	my_player_instance = load('res://Actors/Player/Player.tscn').instance()
	world.add_child(my_player_instance)
	my_player_instance.global_position = global_span_position
	
	get_tree().set_pause(false)
	return true

# 创建服务器，这里返回一个结果
# 如果一个 IP 被占用就会返回错误
func host_game(port:int, myName: String) -> bool:
	if !is_instance_valid(my_player_instance):
		print_debug('invalid my_player_instance')
		return false
	
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		print_debug('cannot create server while the network peer is connected')
		return false
	
	if is_instance_valid(remote_player_instance):
		print_debug('cannot create server while the remote_player_instance is valid')
		return false
	
	reset_network()
	my_player_info['custom_name'] = myName
	
	var host := NetworkedMultiplayerENet.new()
	var success := host.create_server(port, 2)
	if success != OK:
		print_debug('error host game. info: ', success)
		return false
	
	self.get_tree().network_peer = host
	self.get_tree().refuse_new_network_connections = false
	
	my_id = self.get_tree().get_network_unique_id() # 1
	my_player_instance.set_name("Player" + str(my_id))
	my_player_instance.set_network_master(my_id)
	
	return true

# 创建客户端，加入游戏，需要指定 IP 地址
func join_game(address: String, port:int, myName: String) -> bool:
	if !is_instance_valid(my_player_instance):
		print_debug('invalid my_player_instance')
		return false
		
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		print_debug('cannot join server while the network peer is connected')
		return false
	
	if is_instance_valid(remote_player_instance):
		print_debug('cannot join server while the remote_player_instance is valid')
		return false
	
	reset_network()
	my_player_info['custom_name'] = myName
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_client(address, port)
	if error != OK:
		return false
	
	self.get_tree().network_peer = host
	my_id = self.get_tree().get_network_unique_id()
	my_player_instance.set_name("Player" + str(my_id))
	my_player_instance.set_network_master(my_id)
	
	return true

# 重设网络，重设各个变量，断开所有连接
func reset_network() -> void:
	var world:Node2D = get_tree().current_scene
	
	if is_instance_valid(remote_player_instance):
		if is_instance_valid(world):
			world.remove_child(remote_player_instance)
		remote_player_instance.queue_free()
		remote_player_instance = null
	
	my_id = 0
	my_player_info = player_info_template.duplicate()
#	isMyPlayerDone = false
	
	remote_id = 0
	remote_player_info = player_info_template.duplicate()
#	isRemotePlayerDone = false
	
	if(self.get_tree().has_network_peer()):
		self.get_tree().network_peer.close_connection()
		self.get_tree().refuse_new_network_connections = false
		self.get_tree().network_peer = null
