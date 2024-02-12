extends Node

func main(type: Emotion.Type) -> Color:
	match type:
		Emotion.Type.JOY: return Color.YELLOW
		Emotion.Type.TRUST: return Color.LIME_GREEN
		Emotion.Type.FEAR: return Color.DARK_GREEN 
		Emotion.Type.SURPRISE: return Color.BLUE #return Color.hex(0x84cdee)		#Soft blue
		Emotion.Type.SADNESS: return Color.INDIGO
		Emotion.Type.DISGUST: return Color.VIOLET #return Color.hex(0xc6c1ff)	#Soft lavander
		Emotion.Type.ANGER: return Color.RED
		Emotion.Type.ANTICIPATION: return Color.ORANGE
		_: return Color.BLACK

func core_border(type: Emotion.Type) -> Color:
	return main(type).darkened((0.2))
	
func ray(type: Emotion.Type) -> Color:
	return main(type).lightened(0.1)
	
func additional_ray(type: Emotion.Type) -> Color:
	return main(type).darkened(0.1)

func mandala(type: Emotion.Type) -> Color:
	return HarmonyWheel.complementary(area(type))

func area(type: Emotion.Type) -> Color:
	return HarmonyWheel.soft(main(type), 0.8)

func area_border(type: Emotion.Type) -> Color:
	return area(type).darkened((0.15))
