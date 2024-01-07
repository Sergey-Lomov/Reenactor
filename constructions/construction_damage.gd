class_name ConstructionDamage extends RefCounted

var power: float
var target_group: StructureNodeGroup
var targeting_power: float

func _init(_power: float, _target_group: StructureNodeGroup = null, _targeting_power: float = 0):
	power = _power
	target_group = _target_group
	targeting_power = _targeting_power
