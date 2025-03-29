class_name ScheduleTaskRes
extends Resource

# -- Info keys --
# "jump": jump_index
# "await": receiver_to_await_to_progress
# "time": time_duration_of_task
# "position": marker_position_to_reach
# "vigilant" : looks_for_player
# "waypoints" : node3d_wwith_markers_positions_to_reach

enum PuppetStates {
	IDLE_STATE,
	MOVE_STATE,
	STARE_STATE,
	FOLLOW_STATE,
	DANCE_STATE,
	CHASE_STATE,
	KILL_STATE,
	WANDERING_STATE,
	RETURNING_STATE,
	PATROL_STATE
}

@export var state : PuppetStates = PuppetStates.IDLE_STATE
@export var info : Dictionary[String, Variant]

func get_state() -> StringName:
	match state:
		PuppetStates.MOVE_STATE:
			return &"MoveState"
		PuppetStates.STARE_STATE:
			return &"StareState"
		PuppetStates.FOLLOW_STATE:
			return &"FollowState"
		PuppetStates.DANCE_STATE:
			return &"DanceState"
		PuppetStates.CHASE_STATE:
			return &"ChaseState"
		PuppetStates.KILL_STATE:
			return &"KillState"
		PuppetStates.WANDERING_STATE:
			return &"WanderingState"
		PuppetStates.RETURNING_STATE:
			return &"ReturningState"
		PuppetStates.PATROL_STATE:
			return &"PatrolState"
	return &"IdleState"
