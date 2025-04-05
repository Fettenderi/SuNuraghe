class_name AdvancedSoundPlayer
extends AudioStreamPlayer3D

@export var playing_period := 1.0

var _playing_timer : Timer

var _playing := false:
	set(value):
		if _playing == value: return
		
		_playing = value
		
		if _playing:
			play()
			_playing_timer.start()
		else:
			_playing_timer.stop()

func _ready() -> void:
	_playing_timer = Utils.timer(playing_period, _on_playing_timer_timeout)
	
	add_child(_playing_timer, true)

func request_playing():
	_playing = true

func set_period(value : float) -> void:
	playing_period = value
	_playing_timer.wait_time = playing_period
	
	if playing_period >= _playing_timer.wait_time - _playing_timer.time_left:
		play()

func _on_playing_timer_timeout():
	_playing = false
