extends Node

@export var receiver_resource : ReceiverRes

@export_range(0.0, 1.0, 0.01) var desired_tension := 1.0

@export var arrival_time := 1.0

func _ready() -> void:
	receiver_resource.received.connect(_start.unbind(1))

func _start():
	var tween := create_tween()
	tween.tween_method(_tension_controller, FmodServer.get_global_parameter_by_name("Tension"), desired_tension, arrival_time)

func _tension_controller(value: float):
	FmodServer.set_global_parameter_by_name("Tension", value)
