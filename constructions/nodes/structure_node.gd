class_name StructureNode extends Node

var parent_structure: Structure:
	get:
		var cursor = self
		
		while cursor.get_parent() != null:
			if cursor.get_parent() is Structure:
				return get_parent()
			cursor = cursor.get_parent()
			
		push_error("Construction node out of construction")
		return null

func copy():
	return duplicate()

func affect_priority(_attribute: Structure.Attribute):
	return 0
	
func affected_value(_attribute: Structure.Attribute, value: Variant):
	return value
