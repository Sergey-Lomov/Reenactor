@tool
class_name CVE_PatternsStyleButton extends MenuButton

signal style_selected(style: String)

@onready var styles := CVE_PatternsManager.get_styles_list()

func _ready():
	for style in styles:
		get_popup().add_item(style)
	
	get_popup().index_pressed.connect(_item_selected)

func _item_selected(index: int):
	text = "Style: " + styles[index]
	style_selected.emit(styles[index])
