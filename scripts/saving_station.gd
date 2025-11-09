extends Node3D

@export var receiver_resource : ReceiverRes

#var _delay_timer : Timer

func _ready() -> void:
	if receiver_resource != null:
		receiver_resource.received.connect(_on_interactable_box_signal_emitted)
	
	#_delay_timer = Utils.timer(0.3, _save)
	#add_child(_delay_timer, true)

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	#_delay_timer.start()
	_save()

func _save():
	LevelStats.save_data()
