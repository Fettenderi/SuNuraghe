extends Node3D

func _on_interactable_box_activated() -> void:
	%Truck.visible = not %Truck.visible


func _on_interactable_box_2_activated() -> void:
	%Truck.rotation.y += PI
