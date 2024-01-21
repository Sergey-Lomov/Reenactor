@tool
class_name ContructionVisualEditor extends Control

@export var grid_path: NodePath = NodePath("Grid")
@export var preview_path: NodePath = NodePath("preview")
@export var grid_size: int = 10
@export var cell_size: int = 20

@onready var grid := get_node(grid_path) as GridContainer
@onready var preview := get_node(preview_path) as CVE_Preview

func _ready():
	grid.columns = grid_size
	preview.custom_minimum_size = Vector2(grid_size * cell_size, grid_size * cell_size)
	preview.cell_size = cell_size
	for y in grid_size: 
		for x in grid_size:
			var cell = CVE_GridCell.new()
			cell.off_color = Color.hex(0x09295cff)
			cell.on_color = Color.hex(0x1a4fa2ff)
			cell.custom_minimum_size = Vector2(cell_size, cell_size)
			cell.x = x
			cell.y = y
			grid.add_child(cell)


func _on_generate_pressed():
	var preview_grid: Array = []
	for x in grid_size:
		preview_grid.append([])
		for y in grid_size:
			preview_grid[x].append(false)
	
	for child in grid.get_children():
		var cell = child as CVE_GridCell
		if not cell: continue
		if cell.is_on:			
			preview_grid[cell.x][cell.y] = true
		
	preview.update_content(preview_grid, grid_size)


func _on_debug_pressed():
	preview.switch_debug()

func _on_cve_patterns_style_button_style_selected(style):
	preview.available_patterns = CVE_PatternsManager.get_patterns(style)
