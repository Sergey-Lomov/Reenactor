class_name NAE_MetricsContainer extends VBoxContainer

var metrics: MandalaMetrics:
	set(value):
		metrics = value
		if is_node_ready(): handle_metrics_update()
		
func _ready():
	if metrics: handle_metrics_update()
		
func handle_metrics_update():
	var rows = get_children().filter(func(c): return c is HBoxContainer)
	for i in rows.size():
		match i:
			0: rows[i].get_child(1).text = str(metrics.sectors_count)
			1: rows[i].get_child(1).text = str(metrics.mirroringing)
			2: rows[i].get_child(1).text = str(metrics.baked_count)
			3: rows[i].get_child(1).text = str(metrics.baked_length).pad_decimals(2)
			4: rows[i].get_child(1).text = str(metrics.baked_interval).pad_decimals(2)
			5: rows[i].get_child(1).text = str(metrics.intersections_count)
			6: rows[i].get_child(1).text = str(metrics.intersections_per_sector)
			7: 
				var value = "%0.4f" % metrics.intersections_min_distance
				rows[i].get_child(1).text = value
			8: 
				var value = "%0.4f" % metrics.intersections_max_density
				var adapted = "> 10" if metrics.intersections_max_density > 10 else value
				rows[i].get_child(1).text = adapted
