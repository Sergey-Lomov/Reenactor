class_name MemoryNode extends Node2D

var state: MN_State
var core: MN_Core
var size: Vector2:
	set(value):
		size = value
		if is_node_ready(): update_components_positions()

const core_size := Vector2(200, 200)

func _init(_state: MN_State):
	state = _state
	
func _enter_tree():
	core = MN_Core.new()
	core.size = core_size
	core.state = state.core
	core.position = size * 0.5
	add_child(core)

func _ready():
	update_components_positions()

func update_components_positions():
	core.position = size * 0.5
