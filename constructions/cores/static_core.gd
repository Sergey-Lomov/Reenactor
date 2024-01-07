class_name SN_StaticCore extends SN_Core

const max_durability: float = 20

func _init(_durability: float = max_durability):
	super._init(_durability)

func copy():
	return SN_StaticCore.new(durability)
