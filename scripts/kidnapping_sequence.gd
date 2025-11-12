extends Node

enum KNState {
	START,
	MOVING,
	KIDNAPPING,
	TRANSITIONING
}

@export var receiver_resource : ReceiverRes

@export var sheep_mesh : Node3D
@export var player : Player
@export var cry_emitter : FmodEventEmitter3D
@export var kidnapper : Creature

var _state : KNState = KNState.START

var _elapsed := 0.0

func _ready() -> void:
	if receiver_resource == null:
		print(name + " NON CONFIGURATO")
		return
	
	receiver_resource.received.connect(_start.unbind(1))

func _start() -> void:
	TimeKeeper.stop_dance_mode()
	
	await get_tree().create_timer(0.5).timeout
	
	sheep_mesh.visible = true
	
	await get_tree().create_timer(0.3).timeout
	
	cry_emitter.play()
	
	await get_tree().create_timer(2.5).timeout
	
	get_tree().call_group(&"Enemy", "suspect_player", true)
	
	await get_tree().create_timer(1.3).timeout
	
	_state = KNState.MOVING
	kidnapper.can_kill = false

func _physics_process(delta: float) -> void:
	match _state:
		KNState.MOVING:
			kidnapper.navigation_agent_3d.target_position = player.global_position
			Utils.update_just_speed(kidnapper, 4.0, 2.0, delta)
			if abs((kidnapper.global_position - player.global_position).length()) < 2.0:
				_state = KNState.KIDNAPPING
				player.movement_sm.change_state("DieState", {"bypass_timer": true, "to_look": kidnapper.get_eyes_reference()})
			return
		KNState.KIDNAPPING:
			player.global_position = lerp(player.global_position, kidnapper.jumpscare_position.global_position - Vector3(0.0, 1.662, 0.0), 1.0 - exp(-5.0 * delta))
			_elapsed += delta
			
			if _elapsed >= 3.0:
				Gui.start_kidnap_screen()
				_state = KNState.TRANSITIONING
			return
