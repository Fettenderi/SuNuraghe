extends State

var _is_active := false
var _target_visible := true

func start(_info : Dictionary = {}) -> void:
	_is_active = true
	_target_visible = true
#
func update(info : Dictionary = {}) -> void:
	if info.has("arrived") and not _target_visible:
		state_machine.change_state("WanderingState")

func end() -> void:
	_is_active = false

func _on_eyes_not_visible() -> void:
	if not _is_active: return
	
	_target_visible = false

func _on_eyes_located(_collider: Player) -> void:
	if not _is_active: return
	
	_target_visible = true
