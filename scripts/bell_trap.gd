class_name BellTrap
extends Node3D

@export var emitter_resource : EmitterRes
@export var wool_needed := 1

@onready var _activation_box: ExpandedHitBox = %ActivationBox
@onready var _defuse_box: InteractableBox = %DefuseBox
@onready var _sound_maker: ExpandedHitBox = %SoundMaker
@onready var _mesh: Node3D = %Mesh

var _fused := true

func _ready() -> void:
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

	if emitter_resource != null: return
	
	print("TRAPPOLA NON CONFIGURATA " + name)


func _on_activation_box_body_entered(body: Node3D) -> void:
	if not body is Player: return
	if PlayerStats.disguised: return
	
	_sound_maker.set_enabled(true)
	
	if emitter_resource != null:
		emitter_resource.send_signal(body.global_position)
	
	_defuse()


func _on_defuse_box_signal_emitted(_value: Variant) -> void:
	if PlayerStats.wool_pieces < wool_needed: return
	
	PlayerStats.wool_pieces -= wool_needed
	_defuse()

func _defuse():
	_mesh.visible = false
	_defuse_box.set_active(false)
	_activation_box.set_enabled(false)
	_fused = false

func _load_data(data : GStorage) -> void:
	_fused = bool(data.get_value(Utils.nhash(self) + &"fused"))
	_activation_box.set_enabled(_fused)
	_defuse_box.set_active(_fused)
	_mesh.visible = _fused

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"fused", _fused)
