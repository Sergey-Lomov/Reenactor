class_name Construction extends CharacterBody2D

enum Component {FEATURES_CONTEXT, STRUCTURE, VISUAL, SHAPE}
var componentName = {
	Component.FEATURES_CONTEXT: "FeaturesContext",
	Component.STRUCTURE: "Structure",
	Component.VISUAL: "Visual",
	Component.SHAPE: "Shape",
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
	
var shape: CollisionShape2D:
	get: return getComponent(Component.SHAPE) as CollisionShape2D
	set(value): setComponent(value, Component.SHAPE)

#TODO: temporal implementation, should be removed after proper visual implementation
var radius: float:
	get: return structure.get_child_count() + 2

func _init(_structure: Structure = null, _feature_context: StructureFeatureContext = null, _visual: Node2D = null, _shape: CollisionShape2D = null):
	if _structure != null: structure = _structure	
	if _feature_context != null: features_context = _feature_context
	if _visual != null: visual = _visual
	if _shape != null: shape = _shape

func _enter_tree():
	if visual == null: setVisualByStructure()
	if shape == null: 
		setShapeByStructure()
	elif shape.shape == null:
		setShapeByStructure()

func _on_structure_move_produced(absolute, relative, distance):
	var adapted_relative = relative.rotated(rotation)
	var vector = (absolute + adapted_relative) * distance
	move_and_collide(vector)

func _on_structure_feature_execution_requested(feature: StructureFeature):
	feature.execute(features_context)
	
func _on_structure_selfdestruction_requested():
	queue_free()
	
func getComponent(component: Component):
	return get_node_or_null(componentName[component])
	
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

func setVisualByStructure():
	var new_visual = Node2D.new()
	
	var circle = Circle2D.new()
	circle.radius = radius
	new_visual.add_child(circle)
	
	var cabin = Circle2D.new()
	cabin.radius = 3
	cabin.color = Color.RED
	cabin.position = Vector2(circle.radius, 0)
	new_visual.add_child(cabin)
	
	visual = new_visual
	
func setShapeByStructure():
	var new_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	new_shape.shape = circle
	shape = new_shape
