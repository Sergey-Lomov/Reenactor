class_name Structure extends Node

enum Attribute {
	MOVEMENT_ABSOLUTE_VECTOR,
	MOVEMENT_RELATIVE_VECTOR,
	SPEED,
}

signal selfdestruction_requested()
signal move_produced(absolute: Vector2, relative: Vector2, distance: float)
signal feature_execution_requested(feature: StructureFeature)
#TODO: Check is signal really uses
signal features_list_changed(providers: Array[SN_FeatureProvider])

var nodes: Array:
	get:
		return get_children().filter(func(c): return c is StructureNode)

var featureProviders:
	get:
		return get_children().filter(func(c): return c is SN_FeatureProvider)

func _enter_tree():
	child_entered_tree.connect(_on_child_entered_tree)

func _ready():
	features_list_changed.emit(featureProviders)

func _process(delta):
	var speed = get_attribute(Attribute.SPEED, 0) as float
	var absolute_vector = get_attribute(Attribute.MOVEMENT_ABSOLUTE_VECTOR, Vector2.ZERO) as Vector2
	absolute_vector = absolute_vector.normalized()
	var relative_vector = get_attribute(Attribute.MOVEMENT_RELATIVE_VECTOR, Vector2.ZERO) as Vector2
	relative_vector = relative_vector.normalized()
	move_produced.emit(absolute_vector, relative_vector, speed * delta)

func _on_child_entered_tree(node: Node):
	if node is SN_FeatureProvider:
		(node as SN_FeatureProvider).feature_execution_requested.connect(_on_node_feature_execution_requested)
		if is_node_ready():
			features_list_changed.emit(featureProviders)

func _on_node_feature_execution_requested(feature: StructureFeature):
	feature_execution_requested.emit(feature)

func copy():
	var new = Structure.new()
	
	for child in get_children():
		if child is StructureNode:
			new.add_child(child.copy())
		else:
			new.add_child(child.duplicate())
			
	return new

func request_selfdestruction():
	selfdestruction_requested.emit()
	
func get_attribute(attribute: Attribute, initial_value: Variant):
	var affecters = nodes.duplicate()
	affecters.sort_custom(func(n1, n2): return n1.affect_priority(attribute) < n2.affect_priority(attribute))
	return affecters.reduce(func(value, node): return node.affected_value(attribute, value) , initial_value)
