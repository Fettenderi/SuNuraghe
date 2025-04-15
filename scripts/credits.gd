extends Control

@onready var _text: CenterContainer = %Text

func _ready() -> void:
	var tween := create_tween()
	
	tween.tween_property(_text, "position", Vector2(_text.position.x, -2436.0), 45.0)
