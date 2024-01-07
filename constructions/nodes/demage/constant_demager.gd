class_name SN_ConstantDemager extends StructureNode

var demage: float

func _init(_demage: float = 0):
	demage = _demage
	group = StructureNodeGroup.DAMAGE_SYSTEM

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.DAMAGE:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.DAMAGE:
		value.append(ConstructionDamage.new(demage))
		
	return value

func copy():
	return SN_ConstantDemager.new(demage)
