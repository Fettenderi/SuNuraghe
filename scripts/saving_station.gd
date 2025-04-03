extends Node3D

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	LevelStats.save_data()
