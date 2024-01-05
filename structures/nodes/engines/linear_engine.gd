class_name SN_LinearEngine extends StructureNode

func speed_boost():
	return 0

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.SPEED:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.SPEED:
		return value + speed_boost()
		
	return value
