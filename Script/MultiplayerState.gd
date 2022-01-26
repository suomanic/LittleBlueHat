extends Node

# 定义初始加载的游戏场景
const INITIAL_SCENE := 'res://Levels/InitialLevel/InitialLevel.tscn'

var player_info_template: Dictionary = {'custom_name':'','type':''}

# 基本属性：联网id，名字，类型
var my_id : int = 0
var my_player_info: Dictionary = player_info_template.duplicate()
var my_player_node_name: String = ""
var remote_id : int = 0
var remote_player_info: Dictionary = player_info_template.duplicate()
var remote_player_node_name: String = ""

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
func _on_network_peer_connected(remote_id : int) -> void:
	get_tree().set_pause(true)
	print_debug('player peer ', remote_id, ' connected')
	
	# 通过 rpc_id 将自己的信息远程发送给对方进行注册
	rpc_id(remote_id, 'registerPlayerInfo', var2str(my_player_info))
	
	if self.get_tree().is_network_server():
		self.get_tree().refuse_new_network_connections = true
	

# 每当有终端断开链接，就会调用该方法，不论自身是服务端还是客户端
# ● network_peer_disconnected(id: int)
# 每当此 SceneTree 的 network_peer 与对等方断开连接时发出。
# 当其他客户端与同一服务器断开连接时，客户端会收到通知。
func _on_network_peer_disconnected(remote_id : int) -> void:
	get_tree().set_pause(true)
	print_debug('player peer ', remote_id, ' disconnected')
	# 如果是服务端，删除对方并重置远程玩家相关的变量，重新等待连接
	if self.get_tree().is_network_server():
		remote_id = 0
		remote_player_node_name = ""
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
# 当这个SceneTree的network_peer成功连接到一个服务器时发出。只在客户端发出。
func _on_connected_to_server() -> void:
	print_debug('connected to server')
	pass

# 与服务器断开连接(一般是被t了)，仅当自身是客户端时调用
# ● connection_failed()
# 每当此 SceneTree 的 network_peer 无法与服务器建立连接时发出。仅在客户端上发出。
func _on_server_disconnected() -> void:
	print_debug('lost connection to server')
	get_tree().set_pause(true)
	newGame()
	get_tree().set_pause(false)
	pass

# 与服务器连接失败，仅当自身是客户端时调用
func _on_connection_faileded() -> void:
	print_debug('failed to connect to server')
	pass

# 远程方法，处理来自其他玩家的调用，添加其他玩家的信息到 remote_player_info
# 注意，这个方法实际是其他玩家调用（发送），或者说你通过该方法接收到了来自其他玩家的信息
remote func registerPlayerInfo(remote_info_str: String):
	var remote_id = self.get_tree().get_rpc_sender_id()
	var success = false
	# 如果我方没被连接过，则注册新玩家id和信息
	if(remote_id == 0):
		remote_id = remote_id
		remote_player_node_name = "Player" + str(remote_id)
		var temp_remote_info: Dictionary = str2var(remote_info_str)
		print_debug(remote_info_str, temp_remote_info,temp_remote_info.has_all(['custom_name', 'type']))
		if temp_remote_info != null && temp_remote_info.has_all(['custom_name', 'type']):
			remote_player_info['custom_name'] = temp_remote_info['custom_name']
			remote_player_info['type'] = temp_remote_info['type']
		success = load_remote_player()
	# 如果加载远程玩家失败，则关闭对该远程玩家的连接
	if(!success):
		self.get_tree().network_peer.disconnect_peer(remote_id)
		pass

# 加载远程玩家实体
func load_remote_player() -> bool:
	get_tree().set_pause(true)
	var world:Node2D = get_tree().current_scene
	var spanGlobalPosition = Vector2(0, 20)
	if !is_instance_valid(my_player_instance) || !is_instance_valid(world):
		return false
	
	spanGlobalPosition = my_player_instance.global_position
	
	remote_player_instance = load('res://Actors/Player/Player.tscn').instance()
	remote_player_instance.set_name(remote_player_node_name)
	remote_player_instance.set_network_master(remote_id)
	world.add_child(remote_player_instance)
	remote_player_instance.global_position = spanGlobalPosition
	get_tree().set_pause(false)
	return true

# 更新玩家信息
remote func updatePlayerInfo(remote_info: Dictionary):
	var remote_id = self.get_tree().get_rpc_sender_id()
	# 如果本地储存的远程id和收到的远程id是同一id，则可以更新信息，设置info
	if(remote_id == remote_id):
		remote_player_info = remote_info

# 创建新游戏
func newGame(scene_path: String = INITIAL_SCENE) -> bool:
	get_tree().set_pause(true)
	
	# 初始化
	resetNetwork()
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
	
	var spanGlobalPosition = Vector2(0, 20)
	var tempPlayer:Node2D = null
	for c in world.get_children():
		if c.name.begins_with("Player"):
			tempPlayer = c
			break
	if tempPlayer != null && is_instance_valid(tempPlayer):
		spanGlobalPosition = tempPlayer.global_position
		world.remove_child(tempPlayer)
		tempPlayer.queue_free()
		tempPlayer = null
	
	# 加载玩家（单人）
	my_player_instance = load('res://Actors/Player/Player.tscn').instance()
	world.add_child(my_player_instance)
	my_player_instance.global_position = spanGlobalPosition
	
	get_tree().set_pause(false)
	return true

# 创建服务器，这里返回一个结果
# 如果一个 IP 被占用就会返回错误
func hostGame(port:int, myName: String) -> bool:
	if !is_instance_valid(get_tree().current_scene):
		print_debug('invalid world')
		return false
	
	resetNetwork()
	my_player_info['custom_name'] = myName
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_server(port, 2)
	if error != OK:
		print_debug('error is ', error)
		return false
	
	self.get_tree().network_peer = host
	self.get_tree().refuse_new_network_connections = false
	
	my_id = self.get_tree().get_network_unique_id() # 1
	my_player_node_name = "Player" + str(my_id)
	my_player_instance.set_name(my_player_node_name)
	my_player_instance.set_network_master(my_id)
	
	return true

# 创建客户端，加入游戏，需要指定 IP 地址
func joinGame(address: String, port:int, myName: String) -> bool:
	resetNetwork()
	my_player_info['custom_name'] = myName
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_client(address, port)
	if error != OK:
		return false
	
	self.get_tree().network_peer = host
	my_id = self.get_tree().get_network_unique_id()
	my_player_node_name = "Player" + str(my_id)
	my_player_instance.set_name(my_player_node_name)
	my_player_instance.set_network_master(my_id)
	
	return true

# 重设网络，重设各个变量，断开所有连接
func resetNetwork() -> void:
	my_id = 0
	my_player_node_name = ""
	my_player_info = player_info_template.duplicate()
#	isMyPlayerDone = false
	
	remote_id = 0
	remote_player_node_name = ""
	remote_player_info = player_info_template.duplicate()
#	isRemotePlayerDone = false
	
	if(self.get_tree().has_network_peer()):
		self.get_tree().network_peer.close_connection()
