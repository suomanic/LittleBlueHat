extends Node

# 定义最大连接数量，需要加载的游戏场景
const MAX_PLAYERS := 2
const GAME_SCENE := 'res://Level/TestLevel.tscn'

class PlayerInfo:
	var name: String = ""
	var type: String = "" # fire or ice

# 基本属性：联网id，名字，类型
var myId : int
var myInfo: PlayerInfo
var remotePlayerId : int
var remotePlayerInfo: PlayerInfo

# 这里5个信号都是 Godot High-level multiplayer API 自带信号
func _ready() -> void:
	#var peer = NetworkedMultiplayerENet.new()
	#peer.create_server(PORT, MAX_PLAYERS)
	#get_tree().network_peer = peer
	self.get_tree().connect('network_peer_connected', self, '_on_network_peer_connected')
	self.get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected')
	self.get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	self.get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	self.get_tree().connect('connection_failed', self, '_on_connection_failed')

# 每当有终端连接到自己，就会调用该方法，不论自身是服务端还是客户端
func _on_network_peer_connected(remote_id : int) -> void:
	
	# 通过 rpc_id 将自己的信息远程发送给对方
	self.rpc_id(remote_id, 'setRemotePlayerInfo', myInfo)
	
	# 如果自身是服务端，则处理游戏准备事件
	if self.get_tree().is_network_server():
		print_debug(remote_id, 'connected')

# 每当有终端断开链接，就会调用该方法，不论自身是服务端还是客户端
func _on_network_peer_disconnected(remote_id : int) -> void:
	pass

# 连接到服务端成功，仅当自身是客户端时调用
func _on_connected_to_server() -> void:
	pass

# 与服务器断开连接(被t了)，仅当自身是客户端时调用
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
	if(remotePlayerId == null):
		remotePlayerId = remote_id
		remotePlayerInfo = remote_info
	# 如果是同一id，则说明不是注册信息而是更新信息，只设置info
	elif(remotePlayerId == remote_id):
		remotePlayerInfo = remote_info
	else:
		return false
	return true

# 创建服务器，这里返回一个结果
# 如果一个 IP 被占用就会返回错误
func hostGame(port:int, myName: String) -> bool:
	resetNetwork()
	
	var host := NetworkedMultiplayerENet.new()
	var error := host.create_server(port, MAX_PLAYERS)
	if error != OK:
		return false
	
	self.get_tree().network_peer = host
	self.get_tree().refuse_new_network_connections = false
	
	myId = self.get_tree().get_network_unique_id() # 1
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
	myInfo.name = myName
	
	return true

# 重设网络为 null ，断开所有连接
func resetNetwork() -> void:
	myId = 0
	myInfo = PlayerInfo.new()
	remotePlayerId = 0
	remotePlayerInfo = PlayerInfo.new()
	if(self.get_tree().network_peer != null):
		self.get_tree().network_peer.close_connection()
	self.get_tree().network_peer = null
