extends Node3D

@export var receiver_resource : ReceiverRes

func _ready() -> void:
	if receiver_resource != null:
		receiver_resource.received.connect(_on_interactable_box_signal_emitted)

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	LevelStats.save_data()
