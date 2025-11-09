extends Node3D

@export var emitter_resource : EmitterRes
@export var campanas : Campanas

@onready var mesh: Node3D = %Mesh
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter
@onready var _interactable_box: InteractableBox = %InteractableBox

@export var wool_required := 6

var _is_active := true

var _has_been_tampered := false

func _ready() -> void:
	if emitter_resource == null:
		print("CAMPANA NON COLLEGATA " + name)
		return

	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _is_active: return
	if PlayerStats.wool_pieces < wool_required: return
	
	_has_been_tampered = true
	_is_active = false
	_interactable_box.is_active = false
	mesh.visible = true
	campanas.stop()
	_sfx_emitter.play()
	PlayerStats.wool_pieces -= wool_required
	Gui.remove_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_required))
	
	if emitter_resource != null:
		emitter_resource.send_signal(true)

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self)): return

	_has_been_tampered = true

	_is_active = data.get_value(Utils.nhash(self))[&"is_active"]
	mesh.visible = not _is_active
	if not _is_active:
		campanas.stop()
	_interactable_box.is_active = _is_active

func _save_data(data : GStorage) -> void:
	if not _has_been_tampered: return 
	
	data.set_value(Utils.nhash(self), {
		&"is_active" : _is_active
	})


func _on_interactable_box_area_entered(_area: Area3D) -> void:
	if not _is_active: return
	Gui.append_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_required))


func _on_interactable_box_area_exited(_area: Area3D) -> void:
	if not _is_active: return
	
	Gui.remove_requirements(str(PlayerStats.wool_pieces) + " / " + str(wool_required))
