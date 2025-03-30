extends Node

@export var player_input_buffer_time := 0.5
@export var dance_input_buffer_time := 1.3

@export var is_active := false

var _player_input_buffered := false:
	set(value):
		_player_input_buffered = value
		
		if value: _player_input_buffer.start()
		else: _player_input_buffer.stop()
		
var _player_input_buffer : Timer

var _dance_input_buffered := false:
	set(value):
		_dance_input_buffered = value
		
		if value: _dance_input_buffer.start()
		else: _dance_input_buffer.stop()
		
var _dance_input_buffer : Timer

func _ready() -> void:
	_player_input_buffer = Utils.timer(player_input_buffer_time, _on_player_input_expired)
	_dance_input_buffer = Utils.timer(dance_input_buffer_time, _on_dance_input_expired)
	
	add_child(_player_input_buffer, true)
	add_child(_dance_input_buffer, true)

func set_dance_mode(value : bool) -> void:
	is_active = value
	
	_reset_buffers()

func player_input():
	if not is_active: return
	
	if _dance_input_buffered:
		_correct_input()
		return
	_player_input_buffered = true

func dance_input():
	if not is_active: return
	
	if _player_input_buffered:
		_correct_input()
		return
	_dance_input_buffered = true

func _on_player_input_expired():
	_player_input_buffered = false
	_wrong_input()

func _on_dance_input_expired():
	_dance_input_buffered = false
	_wrong_input()

func _reset_buffers():
	_player_input_buffered = false
	_dance_input_buffered = false

func _correct_input():
	_reset_buffers()
	#print("OK")

func _wrong_input():
	_reset_buffers()
	get_tree().call_group(&"Enemy", "suspect_player")
	#print("NOT OK")
