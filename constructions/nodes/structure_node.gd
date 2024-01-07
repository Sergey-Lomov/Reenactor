class_name StructureNode extends Node

signal broken(node: StructureNode)

var group := StructureNodeGroup.UNSPEC
var durability: float = 1:
	set(value):
		durability = max(value, 0)
		if durability == 0: broken.emit(self)

var parent_structure: Structure:
	get:
		var cursor = self
		
		while cursor.get_parent() != null:
			if cursor.get_parent() is Structure:
				return get_parent()
			cursor = cursor.get_parent()
			
		push_error("Construction node out of construction")
		return null

func _init(_durability: float = 1):
	durability = _durability

func copy():
	return duplicate()

func affect_priority(_attribute: Structure.Attribute):
	return 0
	
func affected_value(_attribute: Structure.Attribute, value: Variant):
	return value

func damage_taken_priority():
	return group.damage_priority
	
func is_damagable():
	return durability > 0
