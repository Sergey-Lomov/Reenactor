class_name ShaderRenderable extends Node2D

var renderer: ShaderMaterial:
	get: 
		if material:
			if material is ShaderMaterial:
				return material
		
		material = ShaderMaterial.new()
		material.shader = get_shader()
		setup_renderer_constants()
		return material

# Should be overrided in derived class
func get_shader() -> Shader:
	return Shader.new()

# Should be overrided in derived class
func get_size() -> Vector2:
	return Vector2.ZERO

func _draw():
	draw_rect(Rect2(get_size() * -0.5, get_size()), Color.WHITE)
	
func set_renderer_parameter(name: StringName, value: Variant):
	renderer.set_shader_parameter(name, value)

func update_renderer_size():
	set_renderer_parameter("texture_size", get_size())
	queue_redraw()

#This method may be overloaded to setup shader params, which willn't change
func setup_renderer_constants():
	pass
