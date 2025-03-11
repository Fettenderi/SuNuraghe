extends CSGBox3D

@export var final_y : float
@export var final_y_size : float 

func _ready() -> void:
	size.y = final_y_size
	position.y = final_y
