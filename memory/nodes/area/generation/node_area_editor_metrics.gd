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
				var value = metrics.intersections_min_distance
				var text = "-" if is_inf(value) else str(value).pad_decimals(4)
				rows[i].get_child(1).text = text
			8: rows[i].get_child(1).text = str(metrics.intersections_max_density).pad_decimals(5)
