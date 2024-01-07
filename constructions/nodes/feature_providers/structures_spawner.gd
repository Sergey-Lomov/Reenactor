class_name SN_StructuresSpawner extends SN_FeatureProvider

var blueprint: Structure

func _init(_blueprint: Structure = null):
	super._init()
	blueprint = _blueprint

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
		var feature = SF_StructuresSpawning.new(instance)
		feature_execution_requested.emit(feature)
