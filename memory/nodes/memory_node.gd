class_name MemoryNode extends Node2D


var core: MN_Core
var area: MN_Area
var mandala: MN_Mandala
var absorbers: Array[MN_EtherAbsorber]

var state: MN_State
var size: Vector2:
	set(value):
		size = value
		if is_node_ready(): update_components_positions()
var radius: float:
	get: return min(size.x, size.y) / 2
var center: Vector2:
	get: return size * 0.5

const core_size := Vector2(200, 200)
const absorber_radius := 60.0

func _init(_state: MN_State):
	state = _state
	
func _enter_tree():
	setup_area()
	setup_mandala()
	setup_absorbers()
	setup_core()

func _ready():
	update_components_positions()

func setup_area():
	area = MN_Area.new()
	area.radius = radius
	area.state = state.area
	area.position = center
	add_child(area)

func setup_mandala():
	mandala = MN_Mandala.new()
	mandala.size = size
	mandala.state = state.mandala
	mandala.position = center
	
	var buffer = BackBufferCopy.new()
	buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	buffer.add_child(mandala)
	add_child(buffer)
	
func setup_core():
	core = MN_Core.new()
	core.size = core_size
	core.state = state.core
	core.position = center
	
	var buffer = BackBufferCopy.new()
	buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	buffer.add_child(core)
	add_child(buffer)

func setup_absorbers():
	var angles = state.absorbers_angles
	absorbers = []
	
	if angles.size() != state.absorbers.size():
		printerr("Absorbers state count not equal mandala vertices count at memory node setup")
		return
		
	for i in state.absorbers.size():
		var absorber = MN_EtherAbsorber.new()
		absorber.state = state.absorbers[i]
		absorber.state.orientation = angles[i]
		absorber.position = Vector2.from_angle(angles[i]) * radius + center
		absorber.radius = absorber_radius	
		absorbers.append(absorber)	
		add_child(absorber)

func update_components_positions():
	core.position = center
	area.radius = radius
	area.position = center
	mandala.size = size
	mandala.position = center
