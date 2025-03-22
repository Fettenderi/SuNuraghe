extends State

var _is_active := false
var _stare_target : Vector3

var _stare_timer : Timer

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("time"):
		_stare_timer = Utils.timer(info["time"], _on_stare_timer_ended, _stare_timer)
		
		if not _stare_timer.is_inside_tree():
			add_child(_stare_timer, true)
		
		_stare_timer.start()

func update(info : Dictionary = {}) -> void:
	if info.has("located"):
		_stare_target = info["located"]

func end() -> void:
	_is_active = false

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	user.look(_stare_target, delta)

func _on_stare_timer_ended() -> void:
	if not _is_active: return
	
	_stare_timer.stop()
	user.progress()
