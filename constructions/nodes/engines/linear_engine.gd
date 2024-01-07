class_name SN_LinearEngine extends StructureNode

var boost: float

func _init(_boost: float = 0):
	group = StructureNodeGroup.ENGINE
	boost = _boost

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.SPEED:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.SPEED:
		return value + boost
		
	return value
