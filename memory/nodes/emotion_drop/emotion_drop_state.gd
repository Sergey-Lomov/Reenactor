class_name MN_EmotionDropState extends BaseState

enum Update {
	NODE_PRIMARY_EMOTION,
	DROP_EMOTION,
}

const value := 10.0

@export var emotion: Emotion.Type:
	set(value):
		var old = emotion
		emotion = value
		state_updated.emit(Update.DROP_EMOTION, old, value)

var node_primary_emotion: Emotion.Type:
	get: return (parent as MN_EmotionDropPathState).node_primary_emotion

func _init(_emotion: Emotion.Type = Emotion.Type.NONE):
	emotion = _emotion

func parent_updates_mapping():
	return {
		MN_EmotionDropPathState.Update.NODE_PRIMARY_EMOTION: Update.NODE_PRIMARY_EMOTION,
	}
