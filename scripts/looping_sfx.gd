extends AudioStreamPlayer3D

func _ready() -> void:
	finished.connect(_replay)

func _replay():
	play()
