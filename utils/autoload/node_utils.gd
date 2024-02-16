extends Node

func parent_by_type(node: Node, type: Variant, error_message: String):
	var cursor = node
		
	while cursor != null:
		if is_instance_of(cursor, type):
			return cursor
		cursor = cursor.get_parent()
			
	printerr(error_message)
	return null
