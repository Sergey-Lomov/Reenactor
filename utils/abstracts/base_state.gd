class_name BaseState extends Resource

signal value_chagned(parameter: Variant)

var parent: BaseState:
	set(value):
		if parent: parent.value_chagned.disconnect(handle_parent_value_changed)
		parent = value
		if parent: parent.value_chagned.connect(handle_parent_value_changed)

func handle_parent_value_changed(parameter):
	var mapping = parent_parameters_mapping()
	if mapping.has(parameter):
		value_chagned.emit(mapping[parameter])
	
#May be overrided by derived class
func parent_parameters_mapping() -> Dictionary:
	return {}
