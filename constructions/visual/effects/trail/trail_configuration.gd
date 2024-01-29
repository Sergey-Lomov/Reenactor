class_name CVE_TrailConfiguration extends CVE_EffectConfiguration

enum TrailType {
	UNDEFINED,
	PLASMA,
}

@export var lifeatime: float
@export var disappearing: float

#Should be overrided by derived classes
func get_trail_type() -> TrailType:
	return TrailType.UNDEFINED
	
func get_effect_type() -> CVE_EffectConfiguration.EffectType:
	return CVE_EffectConfiguration.EffectType.TRAIL
