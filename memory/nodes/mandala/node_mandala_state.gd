class_name MN_MandalaState extends BaseState

enum Param {
	PRIMARY_EMOTION,
	CURVES,
}

@export var curves: Array[Curve2D]:
	set(value):
		curves = value
		value_chagned.emit(Param.CURVES)

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion

func parent_parameters_mapping():
	return {
		MN_State.Param.TRANSMUTATION: Param.PRIMARY_EMOTION,
	}

func get_vertices_angles() -> Array[float]:
	var angles: Array[float] = []
	for curve in curves:
		var point = curve.get_point_position(curve.point_count - 1)
		var angle = point.angle()
		if not AdMath.array_has_approx(angles, angle): angles.append(angle)
	return angles
