class_name SN_Navigator extends StructureNode

func affected_absolute_vector(vector: Vector2):
	return vector
	
func affected_relative_vector(vector: Vector2):
	return vector

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.MOVEMENT_ABSOLUTE_VECTOR:
		return 1
	
	if attribute == Structure.Attribute.MOVEMENT_RELATIVE_VECTOR:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.MOVEMENT_ABSOLUTE_VECTOR:
		return affected_absolute_vector(value)
	
	if attribute == Structure.Attribute.MOVEMENT_RELATIVE_VECTOR:
		return affected_relative_vector(value)
		
	return value
