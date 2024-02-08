class_name MemoryNodeCore extends Sprite2D

enum State {
	NORMAL,
	ECLIPSE,
	OBLIVION,
	OVERCHARGE
}

var shader = preload("res://memory/nodes/core/node_core.gdshader")

var size: Vector2
var rect: Rect2:
	get: return Rect2(position - size * 0.5, size)
var ray_count: int
var core_radius: float
 

var state: State
var primary_emotion := EmotionType.NONE
var secondary_emotion := EmotionType.NONE
var energy: float
var ether: float

var transmutation_speed: float
var transmutation_cost: float
var energy_capacity: float
var ether_capacity: float
var awakening_energy: float

const borders_width := 4.0

func _ready():
	material = ShaderMaterial.new()
	material.shader = shader
	update_shader_params()
	
func _draw():
	draw_rect(rect, Color.WHITE)

func update_shader_params():
	var primary_color: Color = AdColor.emotion_color(primary_emotion)
	var secondary_color: Color = AdColor.emotion_color(secondary_emotion) 
	if secondary_emotion == EmotionType.NONE:
		secondary_color = primary_color
	var primary_border = AdColor.emotion_border(primary_color)
	var secondary_border = AdColor.emotion_border(secondary_color)
	
	material.set_shader_parameter("texture_size", size)
	material.set_shader_parameter("zoom", 1.0)
	material.set_shader_parameter("core_color", primary_color)
	material.set_shader_parameter("core_radius", core_radius)
	material.set_shader_parameter("border_color", )
	material.set_shader_parameter("border_width", borders_width)
	
	material.set_shader_parameter("ray_count", ray_count)
	material.set_shader_parameter("ray_color1", primary_color)
	material.set_shader_parameter("ray_border_color1", ray_count)
	material.set_shader_parameter("ray_length1", ray_count)
	material.set_shader_parameter("ray_color2", secondary_color)
	material.set_shader_parameter("ray_border_color2", ray_count)
	material.set_shader_parameter("ray_length2", ray_count)
	material.set_shader_parameter("ray_border_width", borders_width)
	pass
