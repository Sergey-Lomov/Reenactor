class_name MemoryNode extends Node2D

var core: MN_Core
var area: MN_Area
var mandala: MN_Mandala
var absorbers: Array[MN_EtherAbsorber]
var drops_pathes: Array[Path2D]

const core_z := 10
const area_z := 0
const mandala_z := 1
const absorbers_z := 2
const drops_z := 3

var state: MN_State:
	set(value):
		if state: state.value_chagned.disconnect(handle_state_param_updated)
		state = value
		if state: state.value_chagned.connect(handle_state_param_updated)
		handle_state_update()

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
const drop_speed := 50.0

func _init(_state: MN_State):
	state = _state
	
func _ready():
	update_components_positions()

func handle_state_update():
	handle_area_update()
	handle_mandala_update()
	handle_absorbers_update()
	handle_drops_update()
	handle_core_update()
	
func handle_emotion_update():
	handle_area_update()
	handle_mandala_update()
	handle_absorbers_update()
	handle_drops_update()
	handle_core_update()

func handle_state_param_updated(param):
	match param:
		MN_State.Param.CORE: handle_core_update()
		MN_State.Param.AREA: handle_area_update()
		MN_State.Param.MANDALA: handle_mandala_update()
		MN_State.Param.ABSORBERS: handle_absorbers_update()
		MN_State.Param.DROPS_PATHS: handle_drops_update()
		MN_State.Param.TRANSMUTATION: handle_emotion_update()
		MN_State.Param.ABSORBERS_ANGLES: update_absorbers_positions()

func handle_area_update():
	if area: area.queue_free()
	
	area = MN_Area.new()
	area.radius = radius
	area.state = state.area
	area.position = center
	area.z_index = area_z
	add_child(area)

func handle_mandala_update():
	if mandala: mandala.queue_free()
	
	mandala = MN_Mandala.new()
	mandala.size = size
	mandala.state = state.mandala
	mandala.position = center
	
	var buffer = BackBufferCopy.new()
	buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	buffer.add_child(mandala)
	buffer.z_index = mandala_z
	add_child(buffer)
	
func handle_core_update():
	if core: core.queue_free()
	
	core = MN_Core.new()
	core.size = core_size
	core.state = state.core
	core.position = center
	
	var buffer = BackBufferCopy.new()
	buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	buffer.add_child(core)
	buffer.z_index = core_z
	add_child(buffer)

func update_absorbers_positions():
	var angles = state.absorbers_angles	
	if angles.size() != state.absorbers.size():
		printerr("Absorbers state count not equal mandala vertices count at angles update handling")
		return
	
	for i in state.absorbers.size():
		absorbers[i].state.orientation = angles[i]
		absorbers[i].position = Vector2.from_angle(angles[i]) * radius + center

func handle_absorbers_update():
	for absorber in absorbers:
		absorber.queue_free()
	absorbers = []
	
	var angles = state.absorbers_angles	
	if angles.size() != state.absorbers.size():
		printerr("Absorbers state count not equal mandala vertices count at memory node setup")
		return
		
	for i in state.absorbers.size():
		var absorber = MN_EtherAbsorber.new()
		absorber.state = state.absorbers[i]
		absorber.state.orientation = angles[i]
		absorber.position = Vector2.from_angle(angles[i]) * radius + center
		absorber.radius = absorber_radius
		absorber.ether_absorbed.connect(on_absorbation_completed.bind(absorber))
		absorber.z_index = absorbers_z
		absorbers.append(absorber)
		add_child(absorber)

func handle_drops_update():
	for drop_path in drops_pathes:
		drop_path.queue_free()
	drops_pathes = []
	
	for drop_path_state in state.drops_paths:
		var path = MN_EmotionDropPath.new()
		path.state = drop_path_state
		path.completed.connect(on_drop_path_completed.bind(path))
		path.z_index = drops_z
		drops_pathes.append(path)
		add_child(path)

func update_components_positions():
	core.position = center
	area.radius = radius
	area.position = center
	mandala.size = size
	mandala.position = center
	update_absorbers_positions()

func on_absorbation_completed(absorber: MN_EtherAbsorber):
	var drop_state = MN_EmotionDropState.new(Emotion.Type.ETHER)
	var drop_path_state = MN_EmotionDropPathState.new()
	drop_path_state.drop = drop_state
	drop_path_state.progress = 0.0
	drop_path_state.speed = drop_speed
	
	var curves: Array[Curve2D] = []
	for curve in state.mandala.curves:
		var first = curve.get_point_position(0) * radius * 2 + center
		if first.is_equal_approx(absorber.position):
			curves.append(curve)
			continue
			
		var last = curve.get_point_position(curve.point_count - 1) * radius * 2 + center
		if last.is_equal_approx(absorber.position):
			var revert = AdMath.reversed_curve(curve)
			curves.append(revert)
	
	var path_curve = curves.pick_random()
	path_curve = AdMath.scaled_curve_s(path_curve, radius * 2, radius * 2)
	path_curve = AdMath.translated_curve_g(path_curve, center)
	drop_path_state.curve = path_curve
	state.append_drop_path(drop_path_state)
	
	#var drop_path = MN_EmotionDropPath.new()
	#drop_path.state = drop_path_state
	#add_child(drop_path)

func on_drop_path_completed(path: MN_EmotionDropPath):
	core.consume_emotion_drop(path.drop)
	state.erase_drop_path(path.state)
