class_name ScheduleTaskRes
extends Resource

# "jump": jump_index
# "await": receiver_index_to_await_to_progress
# "await_jump": Vector2i(await_index, jump_index)
# "vigilant" : looks_for_player

@export var state : StringName
@export var info : Dictionary[String, Variant]
