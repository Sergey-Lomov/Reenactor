class_name MN_Area extends ShaderRenderable

var radius: float:
	set(value):
		radius = value
		update_renderer_size()
		
var state: MN_AreaState:
	set(value):
		state = value
		update_renderer_params()

const border_width := 10.0
const connector_mult := 0.05
const connector_displacement := 0.6
const gap := Vector2(2.0, 2.0)

func get_shader() -> Shader:
	return preload("res://memory/nodes/area/node_area.gdshader")
	
func get_size() -> Vector2:
	var size = (radius + border_width) * 2 
	return Vector2(size, size) + gap * 2

func update_renderer_params():
	var main_color = EmColor.area(state.primary_emotion)
	var border_color = EmColor.area_border(state.primary_emotion)
	var connector_radius = radius * connector_mult
	
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("radius", radius)
	set_renderer_parameter("connectors", state.connectors)
	set_renderer_parameter("connectors_count", state.connectors.size())
	set_renderer_parameter("connector_displacement", connector_radius * connector_displacement)
	set_renderer_parameter("connector_radius",connector_radius )
	set_renderer_parameter("border_width", border_width)
	set_renderer_parameter("main_color", main_color)
	set_renderer_parameter("border_color", border_color)
