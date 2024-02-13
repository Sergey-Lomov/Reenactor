class_name MN_EtherAbsorberState extends Resource

@export var primary_emotion: Emotion.Type
@export var orientation: float
@export var sector: float
@export var particle_duration: float		#Time to absorb minimal portion of ether
@export var particles_count: int			#Number of particles absrobes at same time
@export var portion_per_drop: int			#Number of portions necessary to complete one ether drop

var drop_duration: float:
	get: return float(portion_per_drop) / float(particles_count) * particle_duration
