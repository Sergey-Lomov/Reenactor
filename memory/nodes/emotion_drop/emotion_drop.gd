class_name MN_EmotionDrop extends ShaderRenderable

var radius: float:
	set(value):
		radius = value
		handle_radius_update()
		
var state: MN_EmotionDropState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()

const gap: float = 2 #Additional gap for cover edge smoothing
const border_width := 2.0
const default_radius := 6.0

func get_shader() -> Shader:
	return preload("res://addons/CustomNodesManager/geometry/circle_2d.gdshader")

func get_size() -> Vector2:
	var size = (radius + gap) * 2 + border_width #Border width not multiplied by 2, because half of width overlap circle (moves inside radius)
	return Vector2(size, size)

func setup_renderer_constants():
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("border_width", border_width)

func handle_radius_update():
	update_renderer_size()
	set_renderer_parameter("radius", radius)
	
func handle_state_update():
	handle_emotion_update()	

func handle_emotion_update():
	var main_color = EmColor.main(state.emotion)
	var border_color = EmColor.mandala(state.node_primary_emotion)
	set_renderer_parameter("main_color", main_color)
	set_renderer_parameter("border_color", border_color)
	
func on_state_updated(update, _old, _new):
	match update:
		MN_EmotionDropState.Update.NODE_PRIMARY_EMOTION, MN_EmotionDropState.Update.DROP_EMOTION: handle_emotion_update()
