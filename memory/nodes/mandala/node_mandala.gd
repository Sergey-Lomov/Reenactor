class_name MN_Mandala extends ShaderRenderable

var size: Vector2:
	set(value):
		size = value
		update_renderer_size()
	
var state: MN_MandalaState:
	set(value):
		state = value
		update_renderer_params()
		
const lines_width := 10.0
const gap := Vector2(2.0, 2.0)
		
func get_shader() -> Shader:
	return preload("res://memory/nodes/mandala/node_mandala.gdshader")
	
func get_size() -> Vector2:
	return (size + gap) * 2 + Vector2(lines_width, lines_width)

func update_renderer_params():
	var main_color: Color = EmColor.mandala(state.primary_emotion)
	
	var curves: Array[Curve2D] = []
	for curve in state.curves:
		var scaled = AdMath.scaled_curve_g(curve, size);
		curves.append(scaled)
	
	var points: Array[Vector2] = []
	var sizes: Array[int] = []
	for curve in curves:
		points.append_array(curve.get_baked_points())
		sizes.append(curve.get_baked_points().size())
	
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("main_color", main_color)
	set_renderer_parameter("width", lines_width)
	set_renderer_parameter("curves_count", curves.size())
	set_renderer_parameter("points", points)
	set_renderer_parameter("curve_sizes", sizes)
