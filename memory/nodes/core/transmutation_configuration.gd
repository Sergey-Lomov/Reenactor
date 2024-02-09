class_name MN_TransmutationConfig extends Resource

@export var items: Array[MN_TransmutationConfigItem]:
	set(value):
		items = value
		items.sort_custom(func(i1, i2): return i1.weight > i2.weight)

var primary_emotion: Emotion.Type:
	get: 
		if items.is_empty(): return Emotion.Type.NONE
		return items[0].emotion
		
var secondary_emotion: Emotion.Type:
	get: 
		if items.size() < 2: return Emotion.Type.NONE
		return items[1].emotion

func _init(_items: Array[MN_TransmutationConfigItem] = []):
	items = _items	
