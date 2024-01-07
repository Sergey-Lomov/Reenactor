class_name SN_ConstantDamager extends StructureNode

var damage: float

func default_group(): return StructureNodeGroup.DAMAGE_SYSTEM
func default_damage(): return 0

func _init(_damage: float = default_damage()):
	super._init()
	damage = _damage

func affect_priority(attribute: Structure.Attribute):
	if attribute == Structure.Attribute.DAMAGE:
		return 1
		
	return 0
	
func affected_value(attribute: Structure.Attribute, value: Variant):
	if attribute == Structure.Attribute.DAMAGE:
		value.append(ConstructionDamage.new(damage))
		
	return value
