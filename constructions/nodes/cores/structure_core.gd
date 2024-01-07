class_name SN_Core extends StructureNode

var unstability: float		#Zero unstability means fully stable core
var timeleft: float			#Available even for stable cores due to possibility to force destabilisation

var is_stable: bool:
	get: return unstability == 0

func default_group(): return StructureNodeGroup.CORE
func default_unstability(): return 0
func default_timeleft(): return 0

func _init(_unstability: float = default_unstability(), _timeleft: float = default_timeleft()):
	super._init()
	unstability = _unstability
	timeleft = _timeleft

func _process(delta):
	if is_stable: return
	
	timeleft -= delta
	if timeleft <= 0:
		parent_structure.destruction_requested.emit(Construction.DestructionReason.UNSTABILITY)
