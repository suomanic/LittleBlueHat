extends Container

onready var AddressEdit:LineEdit = get_node("MenuMainContainer/ConfigContainer/AddrEdit")
onready var PortEdit:LineEdit = get_node("MenuMainContainer/ConfigContainer/PortEdit")
onready var NameEdit:LineEdit = get_node("MenuMainContainer/ConfigContainer/NameEdit")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_ClientJoinButton_pressed():
	if(AddressEdit != null and PortEdit != null and NameEdit != null):
		print_debug("addr = ", AddressEdit.text, ", port = ", PortEdit.text, ", name = ", NameEdit.text)
		var addr:String = AddressEdit.text
		var port:int = PortEdit.text.to_int()
		var playerName:String = NameEdit.text
		var success:bool = false
		if(!addr.empty() and port >=1024 and port <= 65535 and !playerName.empty()):
			success = MultiplayerState.joinGame(addr, port, playerName)
		print_debug("creating game client ", "success" if success else "failed")
		if(!success):
			pass
	pass # Replace with function body.
