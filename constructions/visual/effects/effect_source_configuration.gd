class_name CVE_SourceConfiguration extends Resource

enum EffectType {
	UNDEFINED,
	TRAIL,
}

#Should be overrided by derived classes
func get_effect_type() -> EffectType:
	return EffectType.UNDEFINED
