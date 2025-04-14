extends NavigationRegion3D

@export var receiver_resource : ReceiverRes

func _ready() -> void:
	bake_navigation_mesh()
	if receiver_resource != null:
		receiver_resource.received.connect(_on_received.unbind(1))

func _on_received() -> void:
	if is_baking(): return
	
	bake_navigation_mesh()
