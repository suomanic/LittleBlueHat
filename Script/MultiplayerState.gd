extends Node

# 定义初始加载的游戏场景
const INITIAL_SCENE := 'res://Levels/GrassLevel.tscn'

class PlayerInfo:
	var name: String = ""
	var type: String = "" # fire or ice


# 基本属性：联网id，名字，类型
var myId : int = 0
var myInfo: PlayerInfo
var myPlayerNodeName: String
var remotePlayerId : int = 0
var remotePlayerInfo: PlayerInfo
var remotePlayerNodeName: String

var myPlayerInstance: Node2D = null
var remotePlayerInstance: Node2D = null

var isMyPlayerDone:bool = false
var isRemotePlayerDone:bool = false


# 这里5个信号都是 Godot High-level multiplayer API 自带信号
func _ready() -> void:
	self.get_tree().connect('network_peer_connected', self, '_on_network_peer_connected')
	self.get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected')
	self.get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	self.get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	self.get_tree().connect('connection_failed', self, '_on_connection_failed')

# 每当和终端连接成功（无论谁是发起方），就会调用该方法，不论自身是服务端还是客户端
func _on_network_peer_connected(remote_id : int) -> void:
	print_debug(remote_id, ' connected')
	
	# 通过 rpc_id 将自己的信息远程发送给对方进行注册
	rpc_id(remote_id, 'registerPlayerInfo', myInfo)
	
	if self.get_tree().is_network_server():
		self.get_tree().refuse_new_network_connections = true
	

# 每当有终端断开链接，就会调用该方法，不论自身是服务端还是客户端
func _on_network_peer_disconnected(remote_id : int) -> void:
	pass

# 连接到服务端成功，仅当自身是客户端时调用
func _on_connected_to_server() -> void:
	pass

# 与服务器断开连接(一般是被t了)，仅当自身是客户端时调用
func _on_server_disconnected() -> void:
	pass

# 与服务器连接失败，仅当自身是客户端时调用
func _on_connection_faileded() -> void:
	pass

# 远程方法，处理来自其他玩家的调用，添加其他玩家的信息到 remotePlayerInfo
# 注意，这个方法实际是其他玩家调用（发送），或者说你通过该方法接收到了来自其他玩家的信息
remote func registerPlayerInfo(remote_info: PlayerInfo) -> bool:
	var remote_id = self.get_tree().get_rpc_sender_id()
	# 如果我方没被连接过，则注册新玩家id和信息
	if(remotePlayerId == 0):
		remotePlayerId = remote_id
		remotePlayerNodeName = "Player" + str(remotePlayerId)
		remotePlayerInfo = remote_info
		pre_configure_game(INITIAL_SCENE)
		return true
	return false

remote func updatePlayerInfo(remote_info: PlayerInfo) -> bool:
	var remote_id = self.get_tree().get_rpc_sender_id()
	# 如果本地储存的远程id和收到的远程id是同一id，则可以更新信息，设置info
	if(remotePlayerId == remote_id):
		remotePlayerInfo = remote_info
		return true
	return false

# 创建服务器，这里返回一个结果
# 如果一个 IP 被占用就会返回错误
func hostGame(port:int, myName: String) -> bool:
	resetNetwork()
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_server(port, 2)
	if error != OK:
		return false
	
	self.get_tree().network_peer = host
	self.get_tree().refuse_new_network_connections = false
	
	myId = self.get_tree().get_network_unique_id() # 1
	myPlayerNodeName = "Player" + str(myId)
	myInfo.name = myName
	
	return true

# 创建客户端，加入游戏，需要指定 IP 地址
func joinGame(address: String, port:int, myName: String) -> bool:
	resetNetwork()
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_client(address, port)
	if error != OK:
		return false
	
	self.get_tree().network_peer = host
	myId = self.get_tree().get_network_unique_id()
	myPlayerNodeName = "Player" + str(myId)
	myInfo.name = myName
	
	return true

# 重设网络为null，重设各个变量，断开所有连接
func resetNetwork() -> void:
	myId = 0
	myPlayerNodeName = ""
	myInfo = PlayerInfo.new()
	isMyPlayerDone = false
	
	remotePlayerId = 0
	remotePlayerNodeName = ""
	remotePlayerInfo = PlayerInfo.new()
	isRemotePlayerDone = false
	
	if(self.get_tree().network_peer != null):
		self.get_tree().network_peer.close_connection()
	self.get_tree().network_peer = null

# 初始化游戏关卡设置，加载好人物和关卡并设置主从关系
func pre_configure_game(level_path: String):
	# Load world
	var world: Node2D = load(level_path).instance()
	get_tree().root.add_child(world)
	
	var spanGlobalPosition = Vector2(0, 20)
	var tempPlayer:Node2D = world.get_node_or_null("Player")
	if tempPlayer != null:
		spanGlobalPosition = tempPlayer.global_position
		world.remove_child(tempPlayer)
	
	# Load my player
	myPlayerInstance = preload('res://Actors/Player/Player.tscn').instance()
	myPlayerInstance.set_name(myPlayerNodeName)
	myPlayerInstance.set_network_master(myId)
	world.add_child(myPlayerInstance)
	myPlayerInstance.global_position = spanGlobalPosition
	
	# Load remote player
	remotePlayerInstance = preload('res://Actors/Player/Player.tscn').instance()
	remotePlayerInstance.set_name(remotePlayerNodeName)
	remotePlayerInstance.set_network_master(remotePlayerId)
	world.add_child(remotePlayerInstance)
	remotePlayerInstance.global_position = spanGlobalPosition
	
	# 先暂停
	get_tree().set_pause(true)
	
	# 向服务端告知自身的游戏关卡设置初始化进度已经完成
	# 自己是服务端的，也要向自身告知
	rpc_id(1, 'set_pre_configure_done')

# only execute when self(receiver) is server
# 远程调用位于服务端的此函数，用于向服务端告知自身的游戏关卡设置初始化进度已经完成，
# 服务端收到后设置对应的player的完成进度为true
master func set_pre_configure_done():
	# 只有服务端才接受该调用
	if not get_tree().is_network_server():
		return
	
	if get_tree().get_rpc_sender_id() == myId:
		isMyPlayerDone = true
		print(myId, ' done')
	elif get_tree().get_rpc_sender_id() == remotePlayerId:
		isRemotePlayerDone = true
		print(remotePlayerId, ' done')
	
	# 如果服务端自身和远程客户端的游戏关卡设置初始化都完成，则让双方都开始游戏
	if isMyPlayerDone and isRemotePlayerDone:
		rpc('post_configure_game')

# only execute when remote(sender) is server
# 所有节点的游戏关卡设置都初始化完成，游戏开始
puppetsync func post_configure_game():
	# 只接收服务端发送的信息
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		print('start game')
