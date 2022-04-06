extends Node

# 将字典内相对当前属性有变动的属性设置到当前属性
# update_if_null: 如果存在值为null的键值，是否要应用于属性
remote func update_property(property_owner_path:String, property_dict: Dictionary, update_if_null:bool = false) -> void:
	var property_owner = self.get_node_or_null(property_owner_path)
	if property_owner == null:
		return
	for key in property_dict.keys():
		var nest_key = key.split(".")
		var real_property_owner = property_owner
		# 查找以.隔开的嵌套项
		for i in range(0,nest_key.size()-1):
			if typeof(real_property_owner) != TYPE_OBJECT : break
			real_property_owner = real_property_owner.get(nest_key[i])
		if typeof(real_property_owner) != TYPE_OBJECT : break
		if real_property_owner.get(nest_key[nest_key.size()-1]) != property_dict.get(key):
			if update_if_null or ((!update_if_null) and property_dict.get(key) != null):
				real_property_owner.set(nest_key[nest_key.size()-1], property_dict.get(key))

# 将当前属性相对last_pack内的属性有变动的放入新字典内返回，并同时更新旧字典（gdscript字典类型是传递引用的）
# update_if_null: 如果存在值为null的属性，是否要应用于键值
func update_property_dict(property_owner_path:String, property_list: PoolStringArray, last_pack: Dictionary = {}, update_if_null:bool = false) -> Dictionary:
	var property_owner = self.get_node_or_null(property_owner_path)
	if property_owner == null:
		return {}
	var new_pack:Dictionary = {}
	for key in property_list:
		var nest_key = key.split(".")
		var value = property_owner
		# 查找以.隔开的嵌套项
		for i in range(0, nest_key.size()):
			if typeof(value) != TYPE_OBJECT : break
			value = value.get(nest_key[i])
		if value!=last_pack.get(key):
			last_pack[key] = value # 更新旧字典
			if update_if_null or ((!update_if_null) and value != null):
				new_pack[key] = value
	return new_pack

# 将字典内相对当前的状态机的状态有变动的状态设置到当前状态机
# statemachine_owner_path: 状态机持有者，指向的对象应该实现get_new_state_by_name方法
# update_if_empty: 如果存在值为空字符串的键值，是否要应用于状态机
remote func update_statemachine(statemachine_owner_path:String, statemachine_dict: Dictionary, update_if_empty:bool = false) -> void:
	var statemachine_owner = self.get_node_or_null(statemachine_owner_path)
	if statemachine_owner == null or (!statemachine_owner.has_method("get_new_state_by_name")):
		return
	for key in statemachine_dict.keys():
		var nest_key = key.split(".")
		var real_statemachine = statemachine_owner
		# 查找以.隔开的嵌套项
		for i in range(0,nest_key.size()):
			if typeof(real_statemachine) != TYPE_OBJECT: break
			real_statemachine = real_statemachine.get(nest_key[i])
		if typeof(real_statemachine) != TYPE_OBJECT \
		or real_statemachine.get("class_name") != "StateMachine" : break
		if real_statemachine.get_curr_state_name() != statemachine_dict.get(key):
			if update_if_empty or ((!update_if_empty) and statemachine_dict.get(key) != ""):
				real_statemachine.change_state(statemachine_owner.get_new_state_by_name(statemachine_dict.get(key)))

# 将当前状态机的状态相对last_pack内的状态机的状态有变动的放入新字典内返回，并同时更新旧字典（gdscript字典类型是传递引用的）
# update_if_empty: 如果获取到的状态名称为空（也就是无状态），是否要应用于键值
func update_statemachine_dict(statemachine_owner_path:String, statemachine_list: PoolStringArray, last_pack: Dictionary = {}, update_if_empty:bool = false) -> Dictionary:
	var statemachine_owner = self.get_node_or_null(statemachine_owner_path)
	if statemachine_owner == null:
		return {}
	var new_pack:Dictionary = {}
	for key in statemachine_list:
		var nest_key = key.split(".")
		var real_statemachine = statemachine_owner
		# 查找以.隔开的嵌套项
		for i in range(0, nest_key.size()):
			if typeof(real_statemachine) != TYPE_OBJECT: break
			real_statemachine = real_statemachine.get(nest_key[i])
		if typeof(real_statemachine) != TYPE_OBJECT \
		or real_statemachine.get("class_name") != "StateMachine" : break
		var state_name = real_statemachine.get_curr_state_name()
		if state_name != last_pack.get(key):
			last_pack[key] = state_name # 更新旧字典
			if update_if_empty or ((!update_if_empty) and state_name != ""):
				new_pack[key] = state_name
	return new_pack

remote func call_func(func_owner_path:String, func_dict: Dictionary):
	var func_owner = self.get_node_or_null(func_owner_path)
	if func_owner == null:
		return
	for key in func_dict.keys():
		var nest_key = key.split(".")
		var real_func_name = nest_key[nest_key.size()-1]
		var arg_array = func_dict.get(key,[])
		var real_func_owner = func_owner
		# 查找以.隔开的嵌套项
		for i in range(0,nest_key.size()-1):
			if typeof(real_func_owner) != TYPE_OBJECT: break
			real_func_owner = real_func_owner.get(nest_key[i])
		if typeof(real_func_owner) != TYPE_OBJECT : break
		real_func_owner.callv(real_func_name, arg_array)
