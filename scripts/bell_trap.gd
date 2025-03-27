class_name BellTrap
extends Node3D

@export var emitter_resource : EmitterRes

@onready var _activation_box: ExpandedHitBox = %ActivationBox
@onready var _defuse_box: InteractableBox = %DefuseBox
@onready var _sound_maker: ExpandedHitBox = %SoundMaker
@onready var _mesh: Node3D = %Mesh

var _fused := true

func _ready() -> void:
	if emitter_resource != null: return
	
	print("TRAPPOLA NON CONFIGURATA")
	

func _on_activation_box_body_entered(body: Node3D) -> void:
	if not body is Player: return
	
	_sound_maker.set_enabled(true)
	
	if emitter_resource != null:
		emitter_resource.send_signal()
	
	_defuse()


func _on_defuse_box_signal_emitted(_value: Variant) -> void:
	_defuse()

func _defuse():
	_mesh.visible = false
	_defuse_box.set_active(false)
	_activation_box.set_enabled(false)
	_fused = false
