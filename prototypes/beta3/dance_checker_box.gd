@tool
extends ExpandedHitBox

@export var receiver_resource : ReceiverRes

var _is_player_shifted := false
var _is_player_inside := false

var _is_in_grace_period := false
var _grace_time := 10.0
var _shift_check_time := 0.5
var _shift_check_timer : Timer

func _ready() -> void:
	
	if receiver_resource != null:
		receiver_resource.received.connect(_on_received.unbind(1))
	
	_shift_check_timer = Utils.timer(_grace_time, _on_shift_check_timer_ended)
	
	add_child(_shift_check_timer, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_received() -> void:
	set_enabled(true)
	_shift_check_timer.start()

func player_shifted(value : bool) -> void:
	_is_player_shifted = value

func _on_body_entered(body : Node3D) -> void:
	if not body is Player: return
	
	_is_player_inside = true
	
	if not _is_in_grace_period and not _is_player_shifted:
		get_tree().call_group(&"Enemy", "suspect_player")

func _on_body_exited(body : Node3D) -> void:
	if not body is Player: return
	
	_is_player_inside = false
	
	get_tree().call_group(&"Enemy", "suspect_player")

func _on_shift_check_timer_ended():
	_is_in_grace_period = false
	
	if not _is_player_inside or not _is_player_shifted:
		get_tree().call_group(&"Enemy", "suspect_player")
	
	_shift_check_timer.start(_shift_check_time)
