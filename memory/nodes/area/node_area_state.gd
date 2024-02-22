class_name MN_AreaState extends BaseState

enum Update {
	PRIMARY_EMOTION,
	ABSORBERS_ANGLES,
}

func parent_updates_mapping():
	return {
		MN_State.Update.TRANSMUTATION: Update.PRIMARY_EMOTION,
		MN_State.Update.ABSORBERS_ANGLES: Update.ABSORBERS_ANGLES,
	}

var primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion

var absorbers_angles: Array[float]:
	get: return (parent as MN_State).absorbers_angles
