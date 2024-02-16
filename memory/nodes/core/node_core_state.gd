class_name MN_CoreState extends BaseState

enum Param {
	ENERGY,
	ETHER,
	RAYS_COUNT,
	EMOTIONS,
	TRASNMUTATION_SPEED,
	ENERGY_CAPACITY,
	ETHER_CAPACITY,
	AWAKENING_ENERGY,
}

@export var energy: float:
	set(value):
		energy = value
		value_chagned.emit(Param.ENERGY)

@export var ether: float:
	set(value):
		ether = value
		value_chagned.emit(Param.ETHER)

@export var rays_count: int:
	set(value):
		rays_count = value
		value_chagned.emit(Param.RAYS_COUNT)
		
@export var transmutation_speed: float:
	set(value):
		transmutation_speed = value
		value_chagned.emit(Param.TRASNMUTATION_SPEED)
		
@export var energy_capacity: float:
	set(value):
		energy_capacity = value
		value_chagned.emit(Param.ENERGY_CAPACITY)
		
@export var ether_capacity: float:
	set(value):
		ether_capacity = value
		value_chagned.emit(Param.ETHER_CAPACITY)
		
@export var awakening_energy: float:
	set(value):
		awakening_energy = value
		value_chagned.emit(Param.AWAKENING_ENERGY)

func parent_parameters_mapping():
	return {MN_State.Param.TRANSMUTATION: Param.EMOTIONS}

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return (parent as MN_State).secondary_emotion
