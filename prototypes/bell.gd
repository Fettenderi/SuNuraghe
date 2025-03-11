extends CSGCylinder3D

@export var final_visible := true

func _ready() -> void:
	visible = final_visible
