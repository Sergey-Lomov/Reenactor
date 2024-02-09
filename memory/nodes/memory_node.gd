class_name MemoryNode extends Node2D

var state: MN_State
var core: MN_Core
var area: MN_Area
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
	
	core = MN_Core.new()
	core.size = core_size
	core.state = state.core
	core.position = size * 0.5
	add_child(core)

func _ready():
	update_components_positions()

func update_components_positions():
	core.position = size * 0.5
	area.size = size
	area.position = size * 0.5
