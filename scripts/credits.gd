extends Control

@onready var _text: CenterContainer = %Text

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	
	var _sprinting := Input.is_anything_pressed()
	_text.position.y = lerp(_text.position.y, -5000.0, 1.0 - exp(-delta * 0.01 * (5.0 if _sprinting else 1.0)))
