class_name MandalaMetrics extends RefCounted

var sectors_count: int
var mirroringing: bool
	
var baked_count: int
var baked_length: float
var baked_interval: float
	
var intersections_count: int
var intersections_per_sector: float:
	get: return intersections_count / float(sectors_count)
var intersections_min_distance: float
var intersections_max_density: float
