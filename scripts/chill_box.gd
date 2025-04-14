extends Area3D

func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)

func _on_entered(body : Node3D):
	if not body is Player: return
	
	var tween := create_tween()
	tween.tween_property(body.mxpad, "volume", 0.0, 3.0)

func _on_exited(body : Node3D):
	if not body is Player: return

	var tween := create_tween()
	tween.tween_property(body.mxpad, "volume", 1.0, 3.0)
