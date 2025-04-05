extends Node

@export var receiver_resource : ReceiverRes
@export var emitter_resource : EmitterRes

@export_subgroup("Configurations")
## If false will se the new light energy ranges, otherwise will set the lights activeness
@export var control_activeness := false

## Ignored if Control Activeness is false
@export var are_active := false

## Ignored if Control Activeness is true
@export var max_energy_difference := 1.0
## Ignored if Control Activeness is true
@export var min_energy_difference := 1.0
## Ignored if Control Activeness is true
@export var range_difference := 1.0

func _ready() -> void:
	if receiver_resource == null:
		print(name + " NON HA RECEIVER IMPOSTATO")
		return
	
	if emitter_resource == null:
		print(name + " NON HA EMITTER IMPOSTATO")
		return
	
	receiver_resource.received.connect(_on_received.unbind(1))


func _on_received() -> void:
	if control_activeness:
		emitter_resource.send_signal(are_active)
	else:
		emitter_resource.send_signal(Vector3(max_energy_difference, min_energy_difference, range_difference))
