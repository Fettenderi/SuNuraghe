extends NavigationRegion3D

@export var receiver_resource : ReceiverRes

var _is_level_ready := false

func _ready() -> void:
	_is_level_ready = true
	bake_navigation_mesh()
	
	if receiver_resource != null:
		receiver_resource.received.connect(_on_received.unbind(1))

func _on_received() -> void:
	if not _is_level_ready: return
	if is_baking(): return

	bake_navigation_mesh()
