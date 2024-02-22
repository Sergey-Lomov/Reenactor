class_name MN_Core extends ShaderRenderable

enum Status {
	NORMAL,
	ECLIPSE,
	OBLIVION,
	OVERCHARGE
}

var status: Status

var size: Vector2:
	set(value):
		size = value
		update_renderer_size()
	
var state: MN_CoreState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()

const borders_width := 4.0
const core_radius_mult := 0.4

func get_shader() -> Shader:
	return preload("res://memory/nodes/core/node_core.gdshader")
	
func get_size() -> Vector2:
	return size

func setup_renderer_constants():
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("border_width", borders_width)
	set_renderer_parameter("ray_border_width", borders_width)

func update_renderer_size():
	super.update_renderer_size()
	var core_radius = min(size.x, size.y) * core_radius_mult * 0.5
	var ray_length = min(size.x, size.y) * (1 - core_radius_mult) * 0.5 - borders_width

	set_renderer_parameter("core_radius", core_radius)
	set_renderer_parameter("ray_length1", ray_length)
	set_renderer_parameter("ray_length2", ray_length)

func handle_state_update():
	handle_emotions_update()
	handle_rays_count_update()

func handle_emotions_update():
	var main_color: Color = EmColor.main(state.primary_emotion)
	var ray1_color: Color = EmColor.ray(state.primary_emotion) 
	var ray2_color = EmColor.ray(state.secondary_emotion) 
	if state.secondary_emotion == Emotion.Type.NONE:
		ray2_color = EmColor.additional_ray(state.primary_emotion)
	
	var primary_border_color = EmColor.core_border(state.primary_emotion)
	var secondary_border_color = EmColor.core_border(state.secondary_emotion)
	if state.secondary_emotion == Emotion.Type.NONE:
		secondary_border_color = primary_border_color
		
	set_renderer_parameter("core_color", main_color)
	set_renderer_parameter("border_color", primary_border_color)
	set_renderer_parameter("ray_color1", ray1_color)
	set_renderer_parameter("ray_border_color1", primary_border_color)
	set_renderer_parameter("ray_color2", ray2_color)
	set_renderer_parameter("ray_border_color2", secondary_border_color)

func handle_rays_count_update():
	set_renderer_parameter("ray_count", state.rays_count)

func on_state_updated(update, _old, _new):
	match update:
		MN_CoreState.Update.RAYS_COUNT: handle_rays_count_update()
		MN_CoreState.Update.EMOTIONS: handle_emotions_update()
		
func consume_emotion_drop(drop: MN_EmotionDrop):
	if drop.state.emotion != Emotion.Type.ETHER:
		printerr("Core try to consume emotion drop with emotion (should be ether)")
	state.ether += drop.state.value
	
