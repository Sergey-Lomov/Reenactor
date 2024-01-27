class_name VE_Trail extends Node2D

#Class described trail point - coords and lifetime
class PointLifetime:
	var coords: Vector2
	var lifetime: float
	
	func _init(_coords: Vector2, _lifetime: float):
		coords = _coords
		lifetime = _lifetime

var points: Array[PointLifetime] = []

#Disappearing animation duration. Is part of point lifetime.
var disappearing_duration: float = 0.0:	
	set(value):
		disappearing_duration = value
		if material: material.set_shader_parameter("disappearing", value)

#Points wrapping rectangle
var rect: Rect2:
	set(value):
		rect = value
		if material: material.set_shader_parameter("texture_size", full_size)
		position = rect.position - get_gap()

#Full size of rendering rect (points wrapping + gaps)
var full_size: Vector2:
	get:
		if rect: return rect.size + get_gap() * 2
		else: return Vector2.ZERO
		
#Should be overrided in dervied classes.
func get_shader() -> Shader:
	return null
	
#Additional randering space around points. May be overrided in dervied classes.
func get_gap() -> Vector2:
	return Vector2.ZERO

#Return value should be equal same value specified in shader. Should be overrided in derived classes.
func get_max_points() -> int:
	return 1

func _ready():
	material = ShaderMaterial.new()
	material.shader = get_shader()
	
	#TODO: remove test code
	#rect = Rect2(get_gap(), Vector2(1000, 800))
	#position = Vector2.ZERO

func _draw():
	draw_rect(Rect2(Vector2.ZERO, full_size), Color.WHITE)

func _process(delta):
	var dead_point: PointLifetime
	for index in points.size() - 1:
		points[index].lifetime -= delta
		if points[index].lifetime <= 0 and index > 0: 
			dead_point = points[index - 1]
	
	if dead_point: remove_point(dead_point)
	
	var lifetimes = points.map(func(p): return p.lifetime)
	
	material.set_shader_parameter("points_count", points.size())
	material.set_shader_parameter("points", get_coords(true))
	material.set_shader_parameter("lifetimes", lifetimes)
	
	queue_redraw()
		
func add_point(coord: Vector2, lifetime: float):
	var point = PointLifetime.new(coord, lifetime)
	points.push_back(point)
	
	#Urgent point removing without appopriate visualization
	if points.size() > get_max_points(): 
		points.pop_front()	
		
	rect = AdditionalMath.points_wrapp_rect(get_coords())
	
func remove_point(point: PointLifetime):
	points.erase(point)
	rect = AdditionalMath.points_wrapp_rect(get_coords())

func get_coords(relative: bool = false) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var mapped = (points.map(func(p): 
		if relative: 
			return p.coords - position
		else: 
			return p.coords
	))
	result.assign(mapped)
	return result
