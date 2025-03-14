extends CanvasLayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("toggle_topcam"):
		visible = not visible
