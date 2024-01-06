class_name Construction extends Node2D

enum Component {FEATURES_CONTEXT, STRUCTURE, VISUAL, BODY}
var componentName = {
	Component.FEATURES_CONTEXT: "FeaturesContext",
	Component.STRUCTURE: "Structure",
	Component.VISUAL: "Visual",
	Component.BODY: "Body",
}

var structure: Structure:
	get: return getComponent(Component.STRUCTURE) as Structure
	set(value): setComponent(value, Component.STRUCTURE)

var features_context: StructureFeatureContext:
	get: return getComponent(Component.FEATURES_CONTEXT) as StructureFeatureContext
	set(value): setComponent(value, Component.FEATURES_CONTEXT)
	
var visual: Node2D:
	get: return getComponent(Component.VISUAL) as Node2D
	set(value): setComponent(value, Component.VISUAL)

#TODO: temporal implementation, should be removed after proper visual implementation
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
		addVisualByStructure()		
		
	if _feature_context != null:
		features_context = _feature_context

func _enter_tree():
	if structure == null:
		structure = get_children().filter(func(c): return c is Structure)[0]
		
	if features_context == null:
		features_context = get_children().filter(func(c): return c is StructureFeatureContext)[0]

func _on_structure_move_produced(absolute, relative, distance):
	var adapted_relative = relative.rotated(rotation)
	position += (absolute + adapted_relative) * distance

func _on_structure_feature_execution_requested(feature: StructureFeature):
	feature.execute(features_context)
	
func _on_structure_selfdestruction_requested():
	queue_free()
	
func getComponent(component: Component):
	return get_node(componentName[component])
	
func setComponent(node: Node, component: Component):
	node.name = componentName[component]
	
	var old_node = get_node_or_null(NodePath(node.name))
	if old_node: 
		remove_child(old_node)
	
	add_child(node)
	connectComponent(component)
	
func connectComponent(component: Component):
	match component:
		Component.FEATURES_CONTEXT:
			pass
		Component.STRUCTURE:
			structure.move_produced.connect(_on_structure_move_produced)
			structure.feature_execution_requested.connect(_on_structure_feature_execution_requested)
			structure.selfdestruction_requested.connect(_on_structure_selfdestruction_requested)
		Component.VISUAL:
			pass
		Component.VISUAL:
			pass

func addVisualByStructure():
	var new_visual = Node2D.new()
	
	var circle = Circle2D.new()
	circle.radius = structure.get_child_count() + 2
	new_visual.add_child(circle)
	
	var cabin = Circle2D.new()
	cabin.radius = 3
	cabin.color = Color.REBECCA_PURPLE
	cabin.position = Vector2(circle.radius, 0)
	new_visual.add_child(cabin)
	
	visual = new_visual
