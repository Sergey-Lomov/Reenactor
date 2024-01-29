class_name CVE_PlasmaTrailConfiguration extends CVE_TrailConfiguration

@export var color: Color
@export var width: float

func get_trail_type() -> TrailType:
	return TrailType.PLASMA
