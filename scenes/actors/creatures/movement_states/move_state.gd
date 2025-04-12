extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

var _is_active := false

var _navigation_agent_3d : NavigationAgent3D

var _emitter : EmitterRes
var _receiver : ReceiverRes

var _on_delay := false 
var _delay_timer : Timer 

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	if info.has("position"):
		var _target : Marker3D = user.get_node(info["position"])
		
		if _target == null:
			print(user.name + " NON HA UN NODEPATH ASSOLUTO")
			return
		_navigation_agent_3d.target_position = _target.global_position
	
	if info.has("speed"):
		max_speed = info["speed"]
	
	if info.has("emitter"):
		_emitter = info["emitter"]
	else:
		_emitter = null
	
	if info.has("await"):
		_receiver = info["await"]
		
		_delay_timer = Utils.timer(0.2, _delay_ended, _delay_timer)
		
		if not _delay_timer.is_inside_tree():
			add_child(_delay_timer, true)
		
		_delay_timer.start()
		_on_delay = true
		
		if not _receiver.received.is_connected(_on_received_signal):
			_receiver.received.connect(_on_received_signal)
	else:
		_receiver = null


func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		#print("OH SCUS TI SONO VENUTO ADDOSSO " + user.name + " " + name)
		return

	if info.has("arrived"):
		if _emitter != null:
			_emitter.send_signal(true)

		if _receiver != null: return
		
		user.progress()

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func end() -> void:
	_is_active = false
	if _delay_timer != null:
		_delay_timer.stop()


func _on_received_signal(_value) -> void:
	if not _is_active or _on_delay: return
	
	_receiver.received.disconnect(_on_received_signal)
	
	user.progress()

func _delay_ended() -> void:
	_on_delay = false
