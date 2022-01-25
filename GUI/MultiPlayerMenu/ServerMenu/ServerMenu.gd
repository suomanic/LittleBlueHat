extends Container

onready var PortEdit:LineEdit = get_node("MenuMainContainer/ConfigContainer/PortEdit")
onready var NameEdit:LineEdit = get_node("MenuMainContainer/ConfigContainer/NameEdit")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_ServerCreateButton_pressed():
	if(PortEdit != null and NameEdit != null):
		print_debug("port = ", PortEdit.text, ", name = ", NameEdit.text)
		var port:int = PortEdit.text.to_int()
		var playerName:String = NameEdit.text
		var success:bool = false
		if(port >=1024 and port <= 65535 and !playerName.empty()):
			success = MultiplayerState.hostGame(port, playerName)
		print_debug("creating game server ", "success" if success else "failed")
		if(!success):
			pass
	pass # Replace with function body.
