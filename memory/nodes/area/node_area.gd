class_name MN_Area extends ShaderRenderable

var radius: float:
	set(value):
		radius = value
		handle_radius_update()
		
var state: MN_AreaState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()

const border_width := 10.0
const connector_mult := 0.05
const connector_displacement := 0.6
const gap := Vector2(2.0, 2.0)

func get_shader() -> Shader:
	return preload("res://memory/nodes/area/node_area.gdshader")
	
func get_size() -> Vector2:
	var size = (radius + border_width) * 2 
	return Vector2(size, size) + gap * 2

func setup_renderer_constants():
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("border_width", border_width)

func handle_state_update():
	handle_absorbers_angles_update()
	handle_emotion_update()	

func handle_emotion_update():
	var main_color = EmColor.area(state.primary_emotion)
	var border_color = EmColor.area_border(state.primary_emotion)
	set_renderer_parameter("main_color", main_color)
	set_renderer_parameter("border_color", border_color)

func handle_absorbers_angles_update():
	set_renderer_parameter("connectors", state.absorbers_angles)
	set_renderer_parameter("connectors_count", state.absorbers_angles.size())

func handle_radius_update():
	update_renderer_size()
	var connector_radius = radius * connector_mult
	
	set_renderer_parameter("radius", radius)
	set_renderer_parameter("connector_displacement", connector_radius * connector_displacement)
	set_renderer_parameter("connector_radius",connector_radius)
	
func on_state_updated(update, _old, _new):
	match update:
		MN_AreaState.Update.PRIMARY_EMOTION: handle_emotion_update()
		MN_AreaState.Update.ABSORBERS_ANGLES: handle_absorbers_angles_update()
