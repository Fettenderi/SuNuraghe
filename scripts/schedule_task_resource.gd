class_name ScheduleTaskRes
extends Resource

# -- Info keys --
# "jump": jump_index
# "await": receiver_to_await_to_progress
# "time": time_duration_of_task
# "position": marker_position_to_reach
# "vigilant" : looks_for_player

@export var state : StringName
@export var info : Dictionary[String, Variant]
