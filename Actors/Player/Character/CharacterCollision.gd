extends Node

var is_bounced := false

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
