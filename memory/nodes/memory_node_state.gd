class_name MN_State extends BaseState

enum Update {
	CORE,
	AREA,
	MANDALA,
	ABSORBERS,
	DROPS_PATHS,
	TRANSMUTATION,
	ABSORBERS_ANGLES,
	DROP_APPENDED,
	DROP_ERASED,
}

@export var core: MN_CoreState:
	set(value):
		var old = core
		if core: core.parent = null
		core = value
		if core: core.parent = self
		state_updated.emit(Update.CORE, old, value)

@export var area: MN_AreaState:
	set(value):
		var old = area
		if area: core.parent = null
		area = value
		area.parent = self
		state_updated.emit(Update.AREA, old, value)
		
@export var mandala: MN_MandalaState:
	set(value):
		var old = mandala
		if mandala: 
			mandala.parent = null
			mandala.state_updated.disconnect(handle_mandala_update)
		mandala = value
		mandala.parent = self
		mandala.state_updated.connect(handle_mandala_update)
		state_updated.emit(Update.MANDALA, old, value)
		
@export var absorbers: Array[MN_EtherAbsorberState] = []:
	set(value):
		var old = absorbers
		for absorber in absorbers: absorber.parent = null
		absorbers = value
		for absorber in absorbers: absorber.parent = self
		state_updated.emit(Update.ABSORBERS, old, value)
		
@export var drops_paths: Array[MN_EmotionDropPathState] = []:
	set(value):
		var old = drops_paths
		for path in drops_paths: path.parent = null
		drops_paths = value
		for path in drops_paths: path.parent = self
		state_updated.emit(Update.DROPS_PATHS, old, value)

@export var transmutation: MN_TransmutationConfig:
	set(value):
		var old = transmutation
		transmutation = value
		state_updated.emit(Update.TRANSMUTATION, old, value)

var primary_emotion: Emotion.Type:
	get: return transmutation.primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return transmutation.secondary_emotion
	
var absorbers_angles: Array[float]:
	get: return mandala.get_vertices_angles()

func append_drop_path(path: MN_EmotionDropPathState):
	path.parent = self
	drops_paths.append(path)
	state_updated.emit(Update.DROP_APPENDED, null, path)
	
func erase_drop_path(path: MN_EmotionDropPathState):
	path.parent = null
	drops_paths.erase(path)
	state_updated.emit(Update.DROP_ERASED, path, null)

func handle_mandala_update(param, _old, _new):
	if param != MN_MandalaState.Update.CURVES: return
	state_updated.emit(Update.ABSORBERS_ANGLES, null, null)
