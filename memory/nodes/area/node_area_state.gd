class_name MN_AreaState extends BaseState

enum Param {
	PRIMARY_EMOTION,
	ABSORBERS_ANGLES,
}

func parent_parameters_mapping():
	return {
		MN_State.Param.TRANSMUTATION: Param.PRIMARY_EMOTION,
		MN_State.Param.ABSORBERS_ANGLES: Param.ABSORBERS_ANGLES,
	}

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion

var absorbers_angles: Array[float]:
	get: return (parent as MN_State).absorbers_angles
