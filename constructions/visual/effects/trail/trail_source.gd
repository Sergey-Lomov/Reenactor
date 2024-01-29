class_name CVE_TrailSource extends ConstructionVisualComponent

var trail: CVE_Trail:
	set(value):
		if trail: visual.cve_manager.remove_protector(trail, self)
		trail = value
		if trail: visual.cve_manager.add_protector(trail, self)

var trail_config: CVE_TrailConfiguration
	
func _process(_delta):
	if not trail:
		if trail_config:
			trail = visual.cve_manager.add_effect(trail_config)
		else:
			printerr("CVE_TrailSource have no configuration")
			return
	trail.add_point(global_position)
