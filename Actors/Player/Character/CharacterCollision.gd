extends Node

var is_bounced := false

func _spring_area_entered(area: Area2D) -> void:
	# 部分area的owner本身目前没有element_state这个变量（比如剑），会卡死游戏
	# 所以用get方法而不是直接引用，get不到会返回null而不是卡死
	is_bounced = true
	
	if area.owner.get("element_state") == "Normal" :
		owner.velocity.y = -300
		owner.movement_module.jump_count = 1
	elif area.owner.get("element_state") == "Ice" :
		pass
