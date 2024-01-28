class_name VE_TrailSource extends ConstructionVisualComponent

var trail: VE_Trail
	
func _process(_delta):
	if not trail: trail = visual.ve_manager.add_trail()
	trail.add_point(global_position)
