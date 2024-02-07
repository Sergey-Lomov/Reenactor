class_name MandalaGenerationConfig extends Resource

@export var points: Array[Vector2]
@export var sectors: int
@export var mirroring: bool

func _init(_points: Array[Vector2] = [], _sectors: int = 1, _mirroring: bool = true):
	points = _points
	sectors = _sectors
	mirroring = _mirroring
