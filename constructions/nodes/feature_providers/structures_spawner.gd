class_name SN_StructuresSpawner extends SN_FeatureProvider

var blueprint: Structure
var custom_team: Variant

func default_blueprint(): return null
func default_custom_team(): return null

func _init(_blueprint: Structure = default_blueprint(), _custom_team: Variant = default_custom_team()):
	super._init()
	blueprint = _blueprint
	custom_team = _custom_team

func _enter_tree():	
	#TODO: remove test blueprint configuration
	if blueprint != null:
		return
	blueprint = Structure.new()
	
	var core = SN_BulletCore.new(1)
	blueprint.add_child(core)
	
	var navigator = SN_BulletNavigator.new()
	blueprint.add_child(navigator)
	
	var engine = SN_BulletEngine.new()
	blueprint.add_child(engine)
	
	var demager = SN_ConstantDamager.new(10)
	blueprint.add_child(demager)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		var instance = blueprint.copy()
		var feature = SF_StructuresSpawning.new(instance, custom_team)
		feature_execution_requested.emit(feature)
