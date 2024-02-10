class_name MemoryNode extends Node2D


var core: MN_Core
var area: MN_Area
var mandala: MN_Mandala

var state: MN_State
var size: Vector2:
	set(value):
		size = value
		if is_node_ready(): update_components_positions()

const core_size := Vector2(200, 200)

func _init(_state: MN_State):
	state = _state
	
func _enter_tree():
	area = MN_Area.new()
	area.size = size
	area.state = state.area
	area.position = size * 0.5
	add_child(area)
	
	mandala = MN_Mandala.new()
	mandala.size = size
	mandala.state = state.mandala
	mandala.position = size * 0.5
	var m_buffer = BackBufferCopy.new()
	m_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	m_buffer.add_child(mandala)
	add_child(m_buffer)
	
	core = MN_Core.new()
	core.size = core_size
	core.state = state.core
	core.position = size * 0.5
	var c_buffer = BackBufferCopy.new()
	c_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	c_buffer.add_child(mandala)
	c_buffer.add_child(core)
	add_child(c_buffer)

func _ready():
	update_components_positions()

func update_components_positions():
	core.position = size * 0.5
	area.size = size
	area.position = size * 0.5
	mandala.size = size
	mandala.position = size * 0.5
