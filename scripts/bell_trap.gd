class_name BellTrap
extends Node3D

@export var emitter_resource : EmitterRes
@export var wool_needed := 1

@onready var _activation_box: ExpandedHitBox = %ActivationBox
@onready var _defuse_box: InteractableBox = %DefuseBox
@onready var _sound_maker: ExpandedHitBox = %SoundMaker
@onready var _mesh: Node3D = %Mesh
@onready var _sfx_defuse: FmodEventEmitter3D = %SFXDefuse
@onready var _sfx_trip: FmodEventEmitter3D = %SFXTrip

var _fused := true

var _has_been_tampered := false

func _ready() -> void:
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _on_activation_box_body_entered(body: Node3D) -> void:
	if not body is Player: return
	if PlayerStats.disguised: return
	
	_sound_maker.set_enabled(true)
	
	if emitter_resource != null:
		emitter_resource.send_signal(body.global_position)
	
	_sfx_trip.play()
	_defuse()


func _on_defuse_box_signal_emitted(_value: Variant) -> void:
	if PlayerStats.wool_pieces < wool_needed: return
	
	PlayerStats.wool_pieces -= wool_needed
	_mesh.visible = true
	_sfx_defuse.play()
	Gui.remove_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_needed))
	_defuse()

func _defuse():
	_has_been_tampered = true
	
	_defuse_box.set_active(false)
	_activation_box.set_enabled(false)
	_fused = false

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self)): return

	_has_been_tampered = true

	if not data.get_value(Utils.nhash(self))[&"fused"]:
		queue_free()
		return


func _save_data(data : GStorage) -> void:
	if not _has_been_tampered: return
	
	data.set_value(Utils.nhash(self), {
		&"fused" : _fused
	})


func _on_defuse_box_area_entered(_area: Area3D) -> void:
	if _fused: return
	Gui.append_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_needed))


func _on_defuse_box_area_exited(_area: Area3D) -> void:
	if _fused: return
	Gui.remove_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_needed))
