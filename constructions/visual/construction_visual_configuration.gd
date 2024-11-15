class_name ConstructionVisualConfiguration extends Resource

@export var cells_count: Vector2 #Size in cells. Construction represenation should be square
@export var cell_size: float #Cell size in pixels
@export var edge: Curve2D	 #Points in curve should be represented in cells coords
@export var edge_width: float
@export var color: Color
@export var gap: Vector2 = default_gap #Gap which will be added around edge curve in cell_sizes
@export var effects: Array[CVE_SourceConfiguration] = [] #Resources for instantiate effects sources

const back_shader = preload("res://constructions/visual/back/construction_background.gdshader")
const default_gap: Vector2 = Vector2(2.0, 2.0)

var size: Vector2:
	get: return (cells_count + gap * 2) * cell_size

var gap_displacement: Vector2:
	get: return gap * cell_size

var adapted_edge: Curve2D:
	get:
		if not edge: return null
		var adapted = AdMath.scaled_curve_s(edge, cell_size, cell_size)
		adapted = AdMath.translated_curve_g(adapted, gap_displacement)
		return adapted

var back_material: Material:
	get:
		var material := ShaderMaterial.new()
		material.shader = back_shader
		
		if not edge: return material
		
		var points = adapted_edge.get_baked_points()
		material.set_shader_parameter("points_count", points.size())
		material.set_shader_parameter("texture_size", size)
		material.set_shader_parameter("color", color)
		
		var act_points: Array[Vector2] = [] 
		for point in points:
			act_points.append(point / size)
		material.set_shader_parameter("points", act_points)
				
		return material

func cell_center(x: int, y: int) -> Vector2:
	return gap_displacement + Vector2(x + 0.5, y + 0.5) * cell_size

func duplicate_config() -> ConstructionVisualConfiguration:
	var new_config = ConstructionVisualConfiguration.new()
	new_config.cells_count = cells_count
	new_config.cell_size = cell_size
	new_config.color = color
	new_config.edge_width = edge_width
	new_config.edge = edge
	new_config.gap = gap
	return new_config

func resized(target_cell_size: float) -> ConstructionVisualConfiguration:
	var new_config = duplicate_config()
	var scale = target_cell_size / cell_size
	new_config.cell_size = target_cell_size
	new_config.edge = AdMath.scaled_curve_s(edge, scale, scale)
	return new_config
	
func trimmed() -> ConstructionVisualConfiguration:
	var result = duplicate_config()
	
	if edge:
		var wrapper := AdMath.curve_points_wrapp_rect(edge)
		var max_size := maxf(wrapper.size.x, wrapper.size.y)
		var left_space = wrapper.position.x
		var top_space = wrapper.position.y
		result.edge = AdMath.translated_curve_s(edge, -left_space, -top_space)
		result.cells_count = wrapper.size
		result.gap = default_gap + Vector2(max_size - wrapper.size.x, max_size - wrapper.size.y) * 0.5
		
	return result

#Convert from editor to ingame version. For now it is only rotation.
func editor_to_ingame() -> ConstructionVisualConfiguration:
	var result = duplicate_config()
	result.edge = AdMath.rotated_curve(edge, PI / 2, cells_count * 0.5)	
	return result
