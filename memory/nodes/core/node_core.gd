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

var state: State
var primary_emotion: EmotionType
var secondary_emotion: EmotionType
var energy: float
var ether: float

var transmutation_speed: float
var transmutation_cost: float
var energy_capacity: float
var ether_capacity: float
var awakening_energy: float

func _ready():
	material = ShaderMaterial.new()
	material.shader = shader
	update_shader_params()
	
func _draw():
	draw_rect(rect, Color.WHITE)

func update_shader_params():
	#material.set_shader_parameter("")
	pass
