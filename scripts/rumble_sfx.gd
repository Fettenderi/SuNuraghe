extends AudioStreamPlayer

var _scary_sound_timer : Timer

func _ready() -> void:
	_scary_sound_timer = Utils.timer(3.0, _make_scary_sound)
	add_child(_scary_sound_timer, true)
	_scary_sound_timer.start(max(randfn(40.0, 1.0), 0.0))

func _make_scary_sound():
	play()
	_scary_sound_timer.start(max(randfn(40.0, 1.0), 0.0))
