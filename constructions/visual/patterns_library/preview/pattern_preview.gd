class_name CVE_PatternPreview extends Control

@export var sequence_path: NodePath
@onready var sequence := get_node(sequence_path) as PointsSequence
@export var grid_path: NodePath
@onready var grid := get_node(grid_path) as SquareGrid
@export var curve_layer_path: NodePath
@onready var curve_layer := get_node(curve_layer_path) as CVE_PatternPreviewCurveLayer

var pattern: CVE_VisualPattern = CVE_VisualPattern.demo1():
	set(value):
		pattern = value
		handle_pattern_update()

var main_requirement_color: Color = Color.LIME_GREEN
var additiona_requirement_color: Color = Color.DARK_GREEN

var curve_color: Color = Color.BISQUE:
	get: return curve_layer.color
	set (value): curve_layer.color = value

const border_space: float = 0.5
const min_halfsize: float = 2

func _ready():	
	update_scale()
	handle_pattern_update()

func handle_pattern_update():
	curve_layer.curve = pattern.curve
	sequence.points = pattern.full_requirements
	
	var pre_size = pattern.pre_requirement.size()
	var main_size = pattern.requirement.size()
	sequence.custom_colors = {}
	for index in sequence.points.size():
		var color := main_requirement_color
		if index < pre_size or index >= pre_size + main_size:
			color = additiona_requirement_color
		sequence.custom_colors[index] = color
		
func update_scale():
	if not pattern: return
	
	var requirements = pattern.full_requirements
	var halfsize = min_halfsize
	
	if not requirements.is_empty(): 
		var max_x = requirements.map(func(p): return p.x).max()
		var max_y = requirements.map(func(p): return p.y).min()
		var min_x = requirements.map(func(p): return p.x).max()
		var min_y = requirements.map(func(p): return p.y).min()
		halfsize = [absf(max_x), absf(max_y), absf(min_x), absf(min_y), min_halfsize].max()
	
	var rows_size = 2 * (halfsize + border_space)
	var coords_scale = minf(size.x / rows_size, size.y / rows_size)
	
	curve_layer.coords_scale = coords_scale
	grid.step = int(coords_scale)
	sequence.coords_scale = coords_scale
	

func _on_resized():
	if is_node_ready():
		update_scale()
