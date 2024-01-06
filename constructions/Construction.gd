class_name Construction extends Node2D

var structure: Structure
var features_context: StructureFeatureContext

var radius: float:
	get:
		var circles = get_children().filter(func(n): return n is Circle2D)
		if circles.is_empty():
			return 10
		else:
			return circles[0].radius

func _init(_structure: Structure = null, _feature_context: StructureFeatureContext = null):
	if _structure != null:
		structure = _structure
		structure.move_produced.connect(_on_structure_move_produced)
		structure.feature_execution_requested.connect(_on_structure_feature_execution_requested)
		structure.selfdestruction_requested.connect(_on_structure_selfdestruction_requested)
		add_child(structure)
		addVisualByStructure()		
		
	if _feature_context != null:
		features_context = _feature_context
		add_child(features_context)

func _enter_tree():
	if structure == null:
		structure = get_children().filter(func(c): return c is Structure)[0]
		
	if features_context == null:
		features_context = get_children().filter(func(c): return c is StructureFeatureContext)[0]

func addVisualByStructure():
	var circle = Circle2D.new()
	circle.radius = structure.get_child_count() + 2
	add_child(circle)
	
	var cabin = Circle2D.new()
	cabin.radius = 3
	cabin.color = Color.REBECCA_PURPLE
	cabin.position = Vector2(circle.radius, 0)
	add_child(cabin)

func _on_structure_move_produced(absolute, relative, distance):
	var adapted_relative = relative.rotated(rotation)
	position += (absolute + adapted_relative) * distance

func _on_structure_feature_execution_requested(feature: StructureFeature):
	feature.execute(features_context)
	
func _on_structure_selfdestruction_requested():
	queue_free()
