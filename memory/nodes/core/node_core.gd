class_name MN_Core extends Sprite2D

enum Status {
	NORMAL,
	ECLIPSE,
	OBLIVION,
	OVERCHARGE
}

var shader = preload("res://memory/nodes/core/node_core.gdshader")

var size: Vector2
var status: Status
	
var state: MN_CoreState:
	set(value):
		state = value
		if is_node_ready(): update_shader_params()

#State proxy properties
var primary_emotion: Emotion.Type:
	get: return state.transmutation.primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return state.transmutation.secondary_emotion

func _ready():
	material = ShaderMaterial.new()
	material.shader = shader
	update_shader_params()
	
func _draw():
	draw_rect(Rect2(size * -0.5, size), Color.WHITE)

func update_shader_params():
	var main_color: Color = EmColor.main(primary_emotion)
	var ray1_color: Color = EmColor.ray(primary_emotion) 
	var ray2_color = EmColor.ray(secondary_emotion) 
	if secondary_emotion == Emotion.Type.NONE:
		ray2_color = EmColor.additional_ray(primary_emotion)
	
	var primary_border_color = EmColor.border(primary_emotion)
	var secondary_border_color = EmColor.border(secondary_emotion)
	if secondary_emotion == Emotion.Type.NONE:
		secondary_border_color = primary_border_color
	
	var core_radius = min(size.x, size.y) * state.core_radius_mult * 0.5
	var ray_length = min(size.x, size.y) * (1 - state.core_radius_mult) * 0.5 - state.borders_width
	
	material.set_shader_parameter("texture_size", size)
	material.set_shader_parameter("zoom", 1.0)
	material.set_shader_parameter("core_color", main_color)
	material.set_shader_parameter("core_radius", core_radius)
	material.set_shader_parameter("border_color", primary_border_color)
	material.set_shader_parameter("border_width", state.borders_width)
	
	material.set_shader_parameter("ray_count", state.rays_count)
	material.set_shader_parameter("ray_color1", ray1_color)
	material.set_shader_parameter("ray_border_color1", primary_border_color)
	material.set_shader_parameter("ray_length1", ray_length)
	material.set_shader_parameter("ray_color2", ray2_color)
	material.set_shader_parameter("ray_border_color2", secondary_border_color)
	material.set_shader_parameter("ray_length2", ray_length)
	material.set_shader_parameter("ray_border_width", state.borders_width)
