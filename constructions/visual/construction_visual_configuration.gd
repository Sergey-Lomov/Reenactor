class_name ConstructionVisualConfiguration extends Resource

@export var cells_count: int #Size in cells. Construction represenation should be square
@export var cell_size: int #Cell size in pixels
@export var edge: Curve2D
@export var edge_width: float
@export var color: Color

const back_shader = preload("res://experimental/costruction_background/construction_background.gdshader")
const gap: float = 2 #Gap which will be added around edge curve in cell_sizes

var size: float:
	get: return (cells_count + gap * 2) * cell_size

var back_material: Material:
	get:
		var material := ShaderMaterial.new()
		material.shader = back_shader
		
		if not edge: return material
		
		var points = edge.get_baked_points()
		material.set_shader_parameter("points_count", points.size())
		material.set_shader_parameter("texture_size", size)
		material.set_shader_parameter("color", color)
		
		var act_points: Array[Vector2] = [] 
		for point in points:
			act_points.append(point / size)
		material.set_shader_parameter("points", act_points)
				
		return material

func resized(target_cell_size: float) -> ConstructionVisualConfiguration:
	var new_config = ConstructionVisualConfiguration.new()
	new_config.cells_count = cells_count
	new_config.cell_size = target_cell_size
	new_config.color = color
	new_config.edge_width = edge_width
	var scale = target_cell_size / cell_size;
	new_config.edge = AdditionalMath.scaled_curve(edge, scale, scale)
	return new_config
