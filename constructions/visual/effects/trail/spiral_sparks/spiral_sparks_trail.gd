class_name CVE_SpiralSparksTrail extends CVE_Trail

const shader = preload("res://constructions/visual/effects/trail/spiral_sparks/spiral_sparks_trail.gdshader")

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
	return Vector2(60, 60)

#Return value should be equal same value specified in shader. Should be overrided in derived classes.
func get_max_points() -> int:
	return 300

func setup(config: CVE_TrailConfiguration):
	super.setup(config)	
	var sparks_config = config as CVE_SpiralSparksTrailConfiguration
	if not sparks_config: return
	color = sparks_config.color
	width = sparks_config.width
