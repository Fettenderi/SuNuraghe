extends State

var _is_active := false
var _direction : Vector3

func start(info : Dictionary = {}) -> void:
	_is_active = true
	if info.has("to_look"):
		_direction = (info["to_look"])# - user.position)
	
	state_machine.stop()

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	#user._head.look_at(_direction)

	#user.quaternion = user.quaternion.slerp(Quaternion(Vector3.UP, _direction.normalized()), 2 * delta)
	user._head.quaternion = user._head.quaternion.slerp(Quaternion(Vector3.RIGHT, _direction.normalized()), 2 * delta)
	
	user.velocity.y -= user._gravity * delta
	
	user.move_and_slide()


func end():
	_is_active = false
