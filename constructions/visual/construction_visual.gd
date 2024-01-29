class_name ConstructionVisual extends Node2D

@export var back_path: NodePath
@export var edge_path: NodePath
@export var cve_manager_path: NodePath

var back: ConstructionBackground
var edge: GradientPath2D
var effects_container: Node2D #Stores effects soursec (effects directly isn't part of construction visual)

#Link out to visual effects manager
var cve_manager: CVE_Manager

var editor_mode := false
var glow := true
var glow_mult: float = 2.0

var zero_centrate: bool: 
	get: return not editor_mode

var config: ConstructionVisualConfiguration:
	set(value):
		config = value
		handle_config_update()

func _ready():
	effects_container = Node2D.new()
	add_child(effects_container)
	
	if back_path:
		back = get_node(back_path)
	else:
		back = ConstructionBackground.new()
		add_child(back)
		
	if edge_path:
		edge = get_node(edge_path)
	else:
		edge = GradientPath2D.new()
		add_child(edge)
		
	if not cve_manager:
		if cve_manager_path:
			cve_manager = get_node(cve_manager_path)
		else:
			if not editor_mode:
				printerr("Visual Efffects Manager missed on Construction Visual _ready")
	
	handle_config_update()

func handle_config_update():
	if not is_node_ready(): return
	if not config:
		if not editor_mode: 
			printerr("Construction visual have no config")
		return
	
	if zero_centrate:
		position = config.size * Vector2(-0.5, -0.5)
	
	var color = config.color * glow_mult if glow else config.color
	color = color.clamp()
	edge.fromColor = color
	edge.toColor = color
	edge.curve = config.adapted_edge
	edge.width = config.edge_width
	edge.queue_redraw()
	
	back.material = config.back_material
	back.size = maxf(config.size.x, config.size.y)
	back.queue_redraw()
	
	for child in effects_container.get_children():
		effects_container.remove_child(child)
		child.queue_free()
			
	for source_config in config.effects:
		instantiate_effect_source(source_config)

func instantiate_effect_source(source_config: CVE_SourceConfiguration):
	var source = null
	
	match source_config.get_effect_type():
		CVE_SourceConfiguration.EffectType.TRAIL:
			source = instantiate_trail_source(source_config)
		
	if source: effects_container.add_child(source)

func instantiate_trail_source(source_config: CVE_SourceConfiguration) -> CVE_TrailSource:
	var trail_source_config = source_config as CVE_TrailSourceConfiguration
	if not trail_source_config:
		printerr("CVE_SourceConfiguration have TRAIL effect type, but isn't CVE_TrailSourceConfiguration")
		return null
	
	var source = CVE_TrailSource.new()
	source.position = config.cell_center(trail_source_config.cell.x, trail_source_config.cell.x)
	source.trail_config = trail_source_config.trail
	
	return source 
