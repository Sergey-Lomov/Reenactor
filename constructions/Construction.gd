class_name Construction extends CharacterBody2D

enum Component {FEATURES_CONTEXT, STRUCTURE, VISUAL, SHAPE}
enum DestructionReason {UNSTABILITY, CORE_BROKEN}
const component_name = {
	Component.FEATURES_CONTEXT: "FeaturesContext",
	Component.STRUCTURE: "Structure",
	Component.VISUAL: "Visual",
	Component.SHAPE: "Shape",
}

var structure: Structure:
	get: return get_component(Component.STRUCTURE) as Structure
	set(value): set_component(value, Component.STRUCTURE)

var features_context: StructureFeatureContext:
	get: return get_component(Component.FEATURES_CONTEXT) as StructureFeatureContext
	set(value): set_component(value, Component.FEATURES_CONTEXT)
	
var visual: ConstructionVisual:
	get: return get_component(Component.VISUAL) as ConstructionVisual
	set(value): set_component(value, Component.VISUAL)
	
var shape: CollisionShape2D:
	get: return get_component(Component.SHAPE) as CollisionShape2D
	set(value): set_component(value, Component.SHAPE)

var is_alive := true
@export var team: String
var unstability: float: 
	get: return structure.unstability

#TODO: temporal implementation, should be removed after proper visual implementation
var radius: float:
	get: return structure.get_child_count() + 2

func _init(_structure: Structure = null, _feature_context: StructureFeatureContext = null, _visual: Node2D = null, _shape: CollisionShape2D = null):	
	if _structure != null: structure = _structure	
	if _feature_context != null: features_context = _feature_context
	if _visual != null: visual = _visual
	if _shape != null: shape = _shape

func _enter_tree():
	if visual == null: set_visual_by_structure()
	if shape == null: 
		set_shape_by_structure()
	elif shape.shape == null:
		set_shape_by_structure()

func _process(_delta):
	rotation = structure.get_attribute(Structure.Attribute.ROTATION) + PI / 2

func _on_structure_move_produced(absolute, relative, distance):
	var adapted_relative = relative.rotated(rotation)
	var vector = (absolute + adapted_relative) * distance
	var collision = move_and_collide(vector)
	
	if collision:
		var partner = collision.get_collider() as Construction
		if partner:
			if is_alive and partner.is_alive:
				handle_construction_collision(partner)

func _on_structure_feature_execution_requested(feature: StructureFeature):
	feature.execute(features_context)
	
func _on_structure_destruction_requested(reason: DestructionReason):
	apply_destruction(reason)

func apply_destruction(_reason: DestructionReason):
	#TODO: Implement chace to drop out unbroken nodes if destruction reason was not unstability
	is_alive = false
	queue_free()

func get_component(component: Component):
	return get_node_or_null(component_name[component])
	
func set_component(node: Node, component: Component):
	node.name = component_name[component]
	
	var old_node = get_node_or_null(NodePath(node.name))
	if old_node: 
		remove_child(old_node)
	
	add_child(node)
	connect_component(component)
	
func connect_component(component: Component):
	match component:
		Component.FEATURES_CONTEXT:
			pass
		Component.STRUCTURE:
			structure.move_produced.connect(_on_structure_move_produced)
			structure.feature_execution_requested.connect(_on_structure_feature_execution_requested)
			structure.destruction_requested.connect(_on_structure_destruction_requested)
		Component.VISUAL:
			pass
		Component.SHAPE:
			pass

func set_visual_by_structure():
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
	
func set_shape_by_structure():
	var new_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	new_shape.shape = circle
	shape = new_shape
	
func produce_damage_to(target: Construction):
	var damage = structure.get_attribute(Structure.Attribute.DAMAGE)
	target.handle_income_damages(damage)
	
func handle_income_damages(damages: Array[ConstructionDamage]):
	if damages.is_empty(): return
	
	var targeting_protection = structure.get_attribute(Structure.Attribute.DAMAGE_TARGETING_PROTECTION)
	var untargetedDamage: float = 0
	var targetedDamage = {}
	
	for damage in damages:
		var group = damage.target_group
		if group == null or damage.targeting_power <= targeting_protection:
			untargetedDamage += damage.power
		else:
			if targetedDamage[group] == null:
				targetedDamage[group] = 0
			targetedDamage[group] += damage.power
	
	structure.apply_damage(untargetedDamage)
	if not is_alive: return
	for target_group in targetedDamage.keys():
		structure.apply_damage(targetedDamage[target_group], target_group)
		if not is_alive: return
	
func handle_construction_collision(partner: Construction):
	if partner.team == self.team:
		return #TODO: Should be replaced by friendly collision
	
	if partner.unstability > self.unstability:
		partner.produce_damage_to(self)
		partner.apply_destruction(DestructionReason.UNSTABILITY)
	elif partner.unstability < self.unstability:
		self.produce_damage_to(partner)
		self.apply_destruction(DestructionReason.UNSTABILITY)
	else:
		self.produce_damage_to(partner)
		partner.produce_damage_to(self)
