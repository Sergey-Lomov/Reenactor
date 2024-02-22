class_name BaseState extends Resource

signal state_updated(update: Variant, old: Variant, new: Variant)

var parent: BaseState:
	set(value):
		if parent: parent.state_updated.disconnect(handle_parent_state_updated)
		parent = value
		if parent: parent.state_updated.connect(handle_parent_state_updated)

func handle_parent_state_updated(update: Variant, old: Variant, new: Variant):
	var mapping = parent_updates_mapping()
	if mapping.has(update):
		state_updated.emit(mapping[update], old, new)
	
#May be overrided by derived class
func parent_updates_mapping() -> Dictionary:
	return {}
