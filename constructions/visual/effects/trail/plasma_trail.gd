class_name VE_PlasmaTrail extends VE_Trail

const shader = preload("res://constructions/visual/effects/trail/plasma_trail.gdshader")

var color := Color.AQUAMARINE
var width := 20.0

#Should be overrided in dervied classes.
func get_shader() -> Shader:
	return shader
	
#Additional randering space around points. May be overrided in dervied classes.
func get_gap() -> Vector2:
	return Vector2(40, 40)

#Return value should be equal same value specified in shader. Should be overrided in derived classes.
func get_max_points() -> int:
	return 300
	
func _ready():
	super._ready()
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("width", width)
	material.set_shader_parameter("disappearing", 2.0)
