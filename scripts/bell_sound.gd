extends AudioStreamPlayer3D

var _bell_timer : Timer

func _ready() -> void:
	_bell_timer = Utils.timer(1.333 * 2.0, _reset_timer)
	add_child(_bell_timer, true)
	
	_bell_timer.start()
	play()

func _reset_timer():
	_bell_timer.start()
	play()
