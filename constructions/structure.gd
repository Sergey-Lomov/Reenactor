class_name Structure extends Node

signal destruction_requested(reason: Construction.DestructionReason)
signal move_produced(absolute: Vector2, relative: Vector2, distance: float)
signal feature_execution_requested(feature: StructureFeature)
#TODO: Check is signal really uses
signal features_list_changed(providers: Array[SN_FeatureProvider])

enum Attribute {
	MOVEMENT_ABSOLUTE_VECTOR,	#Vector2
	MOVEMENT_RELATIVE_VECTOR,	#Vector2
	SPEED,						#float
	DAMAGE,						#Array[ConstructionDamage]
	DAMAGE_TARGETING_PROTECTION	#float
}

var attributes_init_builders := {
	Attribute.MOVEMENT_ABSOLUTE_VECTOR: func(): return Vector2.ZERO,
	Attribute.MOVEMENT_RELATIVE_VECTOR: func(): return Vector2.ZERO,
	Attribute.SPEED: func(): return 0,
	Attribute.DAMAGE: func(): return [] as Array[ConstructionDamage],
	Attribute.DAMAGE_TARGETING_PROTECTION: func(): return 0,
}

var nodes: Array:
	get: return get_children().filter(func(c): return c is StructureNode)

var construction: Construction:
	get: return get_parent() as Construction

var feature_providers: Array:
	get: return get_children().filter(func(c): return c is SN_FeatureProvider)

var cores: Array:
	get: return nodes.filter(func(n): return n.group == StructureNodeGroup.CORE)

var live_cores: Array:
	get: return nodes.filter(func(n): return n.group == StructureNodeGroup.CORE and n.durability > 0)
	
var unstability: float:
	get: return cores.map(func(c): return c.unstability).max()

func _enter_tree():
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)

func _ready():
	features_list_changed.emit(feature_providers)

func _physics_process(delta):
	var speed = get_attribute(Attribute.SPEED) as float
	var absolute_vector = get_attribute(Attribute.MOVEMENT_ABSOLUTE_VECTOR) as Vector2
	absolute_vector = absolute_vector.normalized()
	var relative_vector = get_attribute(Attribute.MOVEMENT_RELATIVE_VECTOR) as Vector2
	relative_vector = relative_vector.normalized()
	move_produced.emit(absolute_vector, relative_vector, speed * delta)

func _on_child_entered_tree(child: Node):
	var node = child as StructureNode
	if not node: return
	node.broken.connect(_on_node_broken)
	
	if node is SN_FeatureProvider:
		(node as SN_FeatureProvider).feature_execution_requested.connect(_on_node_feature_execution_requested)
		if is_node_ready():
			features_list_changed.emit(feature_providers)
			
func _on_child_exiting_tree(child: Node):
	var node = child as StructureNode
	if not node: return
		
	if node is SN_FeatureProvider and is_node_ready():
		features_list_changed.emit(feature_providers)

func _on_node_broken(node: StructureNode):
	if node.group == StructureNodeGroup.CORE:
		if live_cores.is_empty():
			destruction_requested.emit(Construction.DestructionReason.CORE_BROKEN)

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

func request_destruction(reason: Construction.DestructionReason):
	destruction_requested.emit(reason)
	
func get_attribute(attribute: Attribute, initial_value: Variant = null):
	if not initial_value:
		initial_value = attributes_init_builders[attribute].call()
		
	var affecters = nodes.duplicate()
	affecters.sort_custom(func(n1, n2): return n1.affect_priority(attribute) < n2.affect_priority(attribute))
	return affecters.reduce(func(value, node): return node.affected_value(attribute, value) , initial_value)
	
func apply_damage(power: float, target_group: StructureNodeGroup = null):
	var target_nodes = nodes.filter(func(n): return n.group == target_group or target_group == null)
	var damagable = target_nodes.filter(func(n): return n.is_damagable())
	var max_priority = damagable.map(func(n): return n.damage_taken_priority()).max()
	var top_receivers = damagable.filter(func(n): return n.damage_taken_priority() == max_priority)
	var damage_left = power
	
	while damage_left > 0 and not damagable.is_empty():
		while damage_left > 0 and not top_receivers.is_empty():
			var target = top_receivers.pick_random() as StructureNode
			var target_damage = min(target.durability, damage_left)
			target.durability -= target_damage
			damage_left -= target_damage
			top_receivers.erase(target)
			damagable.erase(target)
			
			if not construction.is_alive: damage_left = 0
		
		if damage_left > 0 and not damagable.is_empty():
			max_priority = damagable.map(func(n): return n.damage_taken_priority()).max()
			top_receivers = damagable.filter(func(n): return n.damage_taken_priority() == max_priority)
	
	if damage_left > 0 and target_group != null:
		apply_damage(damage_left)
