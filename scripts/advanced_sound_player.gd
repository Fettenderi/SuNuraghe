class_name AdvancedSoundPlayer
extends FmodEventEmitter3D

@export var playing_period := 1.0

var _playing_timer : Timer

var _playing := false:
	set(value):
		if _playing == value: return
		
		_playing = value
		
		if _playing:
			plays.emit()
			play()
			_playing_timer.start(max(playing_period, 0.7))
		else:
			_playing_timer.stop()

signal plays

func _ready() -> void:
	_playing_timer = Utils.timer(max(playing_period, 0.7), _on_playing_timer_timeout)
	
	add_child(_playing_timer, true)

func request_playing():
	_playing = true

func set_period(value : float) -> void:
	playing_period = value
	_playing_timer.wait_time = max(playing_period, 0.7)
	
	if playing_period >= _playing_timer.wait_time - _playing_timer.time_left:
		plays.emit()
		play()

func _on_playing_timer_timeout():
	_playing = false
