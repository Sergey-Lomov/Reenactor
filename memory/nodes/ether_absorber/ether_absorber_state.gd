class_name MN_EtherAbsorberState extends BaseState

enum Update {
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
		var old = orientation
		orientation = value
		state_updated.emit(Update.ORIENTATION, old, value)
		
@export var sector: float:
	set(value):
		var old = sector
		sector = value
		state_updated.emit(Update.SECTOR, old, value)
		
#Time to absorb minimal portion of ether
@export var particle_duration: float:
	set(value):
		var old = particle_duration
		particle_duration = value
		state_updated.emit(Update.PARTICLE_DURATION, old, value)

#Number of particles absrobes at same time
@export var particles_count: int:
	set(value):
		var old = particles_count
		particles_count = value
		state_updated.emit(Update.PARTICLES_COUNT, old, value)

#Number of portions necessary to complete one ether drop
@export var portions_per_drop: int:
	set(value):
		var old = portions_per_drop
		portions_per_drop = value
		state_updated.emit(Update.PORTIONS_PER_DROP, old, value)

@export var progress: float = 0:
	set(value):
		var old = progress
		progress = clampf(value, 0, 1)
		state_updated.emit(Update.PROGRESS, old, value)

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion
	
var drop_duration: float:
	get: return float(portions_per_drop) / float(particles_count) * particle_duration

func parent_updates_mapping():
	return {
		MN_State.Update.TRANSMUTATION: Update.PRIMARY_EMOTION,
	}
