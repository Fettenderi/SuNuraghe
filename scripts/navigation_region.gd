extends NavigationRegion3D

#@export var receiver_resource : ReceiverRes
#
#
#func _ready() -> void:
	#LevelStats.sig_saves_ready.connect(_on_level_ready)
	#
#func _on_level_ready():
	#bake_navigation_mesh()
	#
	#if receiver_resource != null:
		#receiver_resource.received.connect(_on_received.unbind(1))
#
	#
#func _on_received() -> void:
	#if is_baking(): return
#
	#bake_navigation_mesh()
