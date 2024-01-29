class_name StructureNode extends Node

signal broken(node: StructureNode)

var group: StructureNodeGroup
var durability: float:
	set(value):
		durability = max(value, 0)
		if durability == 0: broken.emit(self)

func default_durability(): return 1
func default_group(): return StructureNodeGroup.UNSPEC

var parent_structure: Structure:
	get: 
		var message = "Construction node out of construction"
		return NodeUtils.parent_by_type(self, Structure, message) as Structure

func _init(_durability: float = default_durability(), _group: StructureNodeGroup = default_group()):
	group = _group
	durability = _durability

func copy():
	var new_node = StructureNode.new()
	for property in get_property_list():
		new_node.set(property.name, self.get(property.name))
	return new_node

func affect_priority(_attribute: Structure.Attribute):
	return 0
	
func affected_value(_attribute: Structure.Attribute, value: Variant):
	return value

func damage_taken_priority():
	return group.damage_priority
	
func is_damagable():
	return durability > 0
