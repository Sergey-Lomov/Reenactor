class_name SN_StaticCore extends StructureCore

const max_durability: float = 20

func _init(_durability: float = max_durability):
	durability = _durability

func copy():
	return SN_StaticCore.new(durability)
