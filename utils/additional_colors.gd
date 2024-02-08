extends Node

func emotion_color(type: EmotionType) -> Color:
	match type:
		EmotionType.JOY: return Color.YELLOW
		EmotionType.TRUST: return Color.LIME_GREEN
		EmotionType.FEAR: return Color.hex(0x84cdee)		#Soft blue
		EmotionType.SURPRISE: return Color.hex(0xc6c1ff)	#Soft lavander
		EmotionType.SADNESS: 
		EmotionType.DISGUST:
		EmotionType.ANGER:
		EmotionType.ANTICIPATION:
