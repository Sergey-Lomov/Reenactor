class_name MN_State extends BaseState

enum Param {
	CORE,
	AREA,
	MANDALA,
	ABSORBERS,
	DROPS_PATHS,
	TRANSMUTATION,
	ABSORBERS_ANGLES,
}

@export var core: MN_CoreState:
	set(value):
		if core: core.parent = null
		core = value
		if core: core.parent = self
		value_chagned.emit(Param.CORE)

@export var area: MN_AreaState:
	set(value):
		if area: core.parent = null
		area = value
		area.parent = self
		value_chagned.emit(Param.AREA)
		
@export var mandala: MN_MandalaState:
	set(value):
		if mandala: 
			mandala.parent = null
			mandala.value_chagned.disconnect(handle_mandala_update)
		mandala = value
		mandala.parent = self
		mandala.value_chagned.connect(handle_mandala_update)
		value_chagned.emit(Param.MANDALA)
		
@export var absorbers: Array[MN_EtherAbsorberState] = []:
	set(value):
		for absorber in absorbers: absorber.parent = null
		absorbers = value
		for absorber in absorbers: absorber.parent = self
		value_chagned.emit(Param.ABSORBERS)
		
@export var drops_paths: Array[MN_EmotionDropPathState] = []:
	set(value):
		for path in drops_paths: path.parent = null
		drops_paths = value
		for path in drops_paths: path.parent = self
		value_chagned.emit(Param.DROPS_PATHS)

func append_drop_path(path: MN_EmotionDropPathState):
	path.parent = self
	drops_paths.append(path)
	value_chagned.emit(Param.DROPS_PATHS)
	
func erase_drop_path(path: MN_EmotionDropPathState):
	path.parent = null
	drops_paths.erase(path)
	value_chagned.emit(Param.DROPS_PATHS)

@export var transmutation: MN_TransmutationConfig:
	set(value):
		transmutation = value
		value_chagned.emit(Param.TRANSMUTATION)

var primary_emotion: Emotion.Type:
	get: return transmutation.primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return transmutation.secondary_emotion
	
var absorbers_angles: Array[float]:
	get: return mandala.get_vertices_angles()

func handle_mandala_update(param):
	if param != MN_MandalaState.Param.CURVES: return
	value_chagned.emit(Param.ABSORBERS_ANGLES)
