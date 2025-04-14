extends Area3D

func _ready() -> void:
	body_entered.connect(_disable_suspects)

func _disable_suspects(body : Node3D) -> void:
	if not body is Creature: return
	
	body.can_suspect = false
