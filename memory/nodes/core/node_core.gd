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
		state = value
		update_renderer_params()

#State proxy properties
var primary_emotion: Emotion.Type:
	get: return state.transmutation.primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return state.transmutation.secondary_emotion

func get_shader() -> Shader:
	return preload("res://memory/nodes/core/node_core.gdshader")
	
func get_size() -> Vector2:
	return size

func update_renderer_params():
	var main_color: Color = EmColor.main(primary_emotion)
	var ray1_color: Color = EmColor.ray(primary_emotion) 
	var ray2_color = EmColor.ray(secondary_emotion) 
	if secondary_emotion == Emotion.Type.NONE:
		ray2_color = EmColor.additional_ray(primary_emotion)
	
	var primary_border_color = EmColor.core_border(primary_emotion)
	var secondary_border_color = EmColor.core_border(secondary_emotion)
	if secondary_emotion == Emotion.Type.NONE:
		secondary_border_color = primary_border_color
	
	var core_radius = min(size.x, size.y) * state.core_radius_mult * 0.5
	var ray_length = min(size.x, size.y) * (1 - state.core_radius_mult) * 0.5 - state.borders_width

	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("core_color", main_color)
	set_renderer_parameter("core_radius", core_radius)
	set_renderer_parameter("border_color", primary_border_color)
	set_renderer_parameter("border_width", state.borders_width)
	
	set_renderer_parameter("ray_count", state.rays_count)
	set_renderer_parameter("ray_color1", ray1_color)
	set_renderer_parameter("ray_border_color1", primary_border_color)
	set_renderer_parameter("ray_length1", ray_length)
	set_renderer_parameter("ray_color2", ray2_color)
	set_renderer_parameter("ray_border_color2", secondary_border_color)
	set_renderer_parameter("ray_length2", ray_length)
	set_renderer_parameter("ray_border_width", state.borders_width)
