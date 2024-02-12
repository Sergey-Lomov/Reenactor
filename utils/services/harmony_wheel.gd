extends Node

func complementary(source: Color) -> Color:
	var h = source.h + 0.5 if source.h <= 0.5 else source.h - 0.5 
	return Color.from_hsv(h, source.s, source.v, source.a)
	
func soft(source: Color, power: float) -> Color:
	return Color.from_hsv(source.h, source.s * (1 - power), source.v, source.a) 
