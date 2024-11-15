class_name StructureNodeGroup extends RefCounted

var name: String
var damage_priority: float

static var UNSPEC := StructureNodeGroup.new("Unspecified", -1)
static var CORE := StructureNodeGroup.new("Core", 5)
static var ENGINE := StructureNodeGroup.new("Engine", 2)
static var FEATURE_PROVIDER := StructureNodeGroup.new("FeatureProvider", 2)
static var DAMAGE_SYSTEM := StructureNodeGroup.new("DamageSystems", 2)
static var DAMAGE_ABSORBER := StructureNodeGroup.new("DamageAbsorber", 10)

func _init(_name: String, _damage_priority: float):
	name = _name
	damage_priority = _damage_priority
