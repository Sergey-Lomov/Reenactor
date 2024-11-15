class_name MN_Mandala extends ShaderRenderable

var size: Vector2 = Vector2.ZERO:
	set(value):
		size = value
		update_renderer_size()
	
var state: MN_MandalaState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()
		
const lines_width := 10.0
const gap := Vector2(2.0, 2.0)
		
func get_shader() -> Shader:
	return preload("res://memory/nodes/mandala/node_mandala.gdshader")
	
func get_size() -> Vector2:
	return (size + gap) * 2 + Vector2(lines_width, lines_width)

func setup_renderer_constants():
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("width", lines_width)

func update_renderer_size():
	super.update_renderer_size()
	handle_curves_update()

func handle_state_update():
	handle_emotion_update()
	handle_curves_update()

func handle_curves_update():
	if not state or size == Vector2.ZERO: return
	
	var curves: Array[Curve2D] = []
	for curve in state.curves:
		var scaled = AdMath.scaled_curve_g(curve, size);
		scaled.bake_interval = 5
		curves.append(scaled)
	
	@warning_ignore("integer_division")
	var sectors = state.curves.size() / 2
	var manager = MandalaManager.new(sectors, true, Vector2.ZERO)
	var lines = manager.lines_in_angle(curves, TAU / sectors)
	
	var from_points = lines.map(func(l): return l.from)
	var to_points = lines.map(func(l): return l.to)

	set_renderer_parameter("sectors", sectors)
	set_renderer_parameter("from_points", from_points)
	set_renderer_parameter("to_points", to_points)
	set_renderer_parameter("lines_count", lines.size())

func handle_emotion_update():
	var main_color: Color = EmColor.mandala(state.primary_emotion)
	set_renderer_parameter("main_color", main_color)

func on_state_updated(param):
	match param:
		MN_MandalaState.Update.PRIMARY_EMOTION: handle_emotion_update()
		MN_MandalaState.Update.CURVES: handle_curves_update()
