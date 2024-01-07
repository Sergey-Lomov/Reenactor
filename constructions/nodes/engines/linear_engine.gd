class_name SN_LinearEngine extends StructureNode

var boost: float

func default_boost(): return 0
func default_group(): return StructureNodeGroup.ENGINE

func _init(_boost: float = default_boost()):
	super._init()
	boost = _boost

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.SPEED:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.SPEED:
		return value + boost
		
	return value
