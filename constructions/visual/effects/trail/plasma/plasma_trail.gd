class_name CVE_PlasmaTrail extends CVE_Trail

const shader = preload("res://constructions/visual/effects/trail/plasma/plasma_trail.gdshader")

var color: Color:	
	set(value): material.set_shader_parameter("color", value)
	get: return material.get_shader_parameter("color")
	
var width: float:	
	set(value): material.set_shader_parameter("width", value)
	get: return material.get_shader_parameter("width")

#Should be overrided in dervied classes.
func get_shader() -> Shader:
	return shader
	
#Additional randering space around points. May be overrided in dervied classes.
func get_gap() -> Vector2:
	return Vector2(40, 40)

#Return value should be equal same value specified in shader. Should be overrided in derived classes.
func get_max_points() -> int:
	return 300

func setup(config: CVE_TrailConfiguration):
	super.setup(config)	
	var plasma_config = config as CVE_PlasmaTrailConfiguration
	if not plasma_config: return
	color = plasma_config.color
	width = plasma_config.width
