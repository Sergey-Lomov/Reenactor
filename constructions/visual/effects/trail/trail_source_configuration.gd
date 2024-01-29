class_name CVE_TrailSourceConfiguration extends CVE_SourceConfiguration

@export var cell: Vector2i
@export var trail: CVE_TrailConfiguration

#Should be overrided by derived classes
func get_effect_type() -> EffectType:
	return EffectType.TRAIL
