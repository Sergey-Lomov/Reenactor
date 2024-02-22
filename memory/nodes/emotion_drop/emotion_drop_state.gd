class_name MN_EmotionDropState extends BaseState

enum Param {
	NODE_PRIMARY_EMOTION,
	DROP_EMOTION,
}

const value := 10.0

@export var emotion: Emotion.Type:
	set(value):
		emotion = value
		value_chagned.emit(Param.DROP_EMOTION)

var node_primary_emotion: Emotion.Type:
	get: return (parent as MN_EmotionDropPathState).node_primary_emotion

func _init(_emotion: Emotion.Type = Emotion.Type.NONE):
	emotion = _emotion

func parent_parameters_mapping():
	return {
		MN_EmotionDropPathState.Param.NODE_PRIMARY_EMOTION: Param.NODE_PRIMARY_EMOTION,
	}
