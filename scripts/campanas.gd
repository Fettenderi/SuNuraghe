class_name Campanas
extends Node3D

@export_range(0.0, 6.5, 0.25) var starting_offset : float
@export_range(1, 4, 1) var size : int

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _sfx_campanas0: FmodEventEmitter3D = %SFXCampanas0
@onready var _sfx_campanas1: FmodEventEmitter3D = %SFXCampanas1

var wants_stop := false

var _first_bell := false

func _ready() -> void:
	if starting_offset > 0.0:
		await get_tree().create_timer(starting_offset).timeout
	
	_animation_player.play("custom/looping")
	
	_sfx_campanas0.set_parameter("Bells_Pitch", size)
	_sfx_campanas1.set_parameter("Bells_Pitch", size)

func stop():
	wants_stop = true

func _actually_stop():
	if not wants_stop: return
	wants_stop = false
	_animation_player.play("custom/stopping")

func play_sound():
	if _first_bell:
		_sfx_campanas0.play()
	else:
		_sfx_campanas1.play()
	
	TimeKeeper.bell_input(size)
	
	_first_bell = not _first_bell
