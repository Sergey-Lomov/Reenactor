class_name VE_TrailSource extends Node2D

var rect: ColorRect


var points: Dictionary = {} #Keys is Vector2 points, values is appearance time
var point_lifetime: float = 2.0
var point_disapearing: float = 0.5

func _ready():
	rect = ColorRect.new()
	add_child(rect)
