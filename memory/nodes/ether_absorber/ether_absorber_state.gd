class_name MN_EtherAbsorberState extends BaseState

enum Param {
	PRIMARY_EMOTION,
	ORIENTATION,
	SECTOR,
	PARTICLE_DURATION,
	PARTICLES_COUNT,
	PORTIONS_PER_DROP,
	PROGRESS,
}

@export var orientation: float:
	set(value):
		orientation = value
		value_chagned.emit(Param.ORIENTATION)
		
@export var sector: float:
	set(value):
		sector = value
		value_chagned.emit(Param.SECTOR)
		
#Time to absorb minimal portion of ether
@export var particle_duration: float:
	set(value):
		particle_duration = value
		value_chagned.emit(Param.PARTICLE_DURATION)

#Number of particles absrobes at same time
@export var particles_count: int:
	set(value):
		particles_count = value
		value_chagned.emit(Param.PARTICLES_COUNT)

#Number of portions necessary to complete one ether drop
@export var portions_per_drop: int:
	set(value):
		portions_per_drop = value
		value_chagned.emit(Param.PORTIONS_PER_DROP)

@export var progress: float = 0:
	set(value):
		progress = clampf(value, 0, 1)
		value_chagned.emit(Param.PROGRESS)

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion
	
var drop_duration: float:
	get: return float(portions_per_drop) / float(particles_count) * particle_duration

func parent_parameters_mapping():
	return {
		MN_State.Param.TRANSMUTATION: Param.PRIMARY_EMOTION,
	}
