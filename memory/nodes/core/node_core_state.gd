class_name MN_CoreState extends BaseState

enum Update {
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
		var old = energy
		energy = value
		state_updated.emit(Update.ENERGY, old, value)

@export var ether: float:
	set(value):
		var old = ether
		ether = value
		state_updated.emit(Update.ETHER, old, value)

@export var rays_count: int:
	set(value):
		var old = rays_count
		rays_count = value
		state_updated.emit(Update.RAYS_COUNT, old, value)
		
@export var transmutation_speed: float:
	set(value):
		var old = transmutation_speed
		transmutation_speed = value
		state_updated.emit(Update.TRASNMUTATION_SPEED, old, value)
		
@export var energy_capacity: float:
	set(value):
		var old = energy_capacity
		energy_capacity = value
		state_updated.emit(Update.ENERGY_CAPACITY, old, value)
		
@export var ether_capacity: float:
	set(value):
		var old = ether_capacity
		ether_capacity = value
		state_updated.emit(Update.ETHER_CAPACITY, old, value)
		
@export var awakening_energy: float:
	set(value):
		var old = awakening_energy
		awakening_energy = value
		state_updated.emit(Update.AWAKENING_ENERGY, old, value)

func parent_updates_mapping():
	return {MN_State.Update.TRANSMUTATION: Update.EMOTIONS}

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion
	
var secondary_emotion: Emotion.Type:
	get: return (parent as MN_State).secondary_emotion
