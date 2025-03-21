class_name ScheduleRes
extends Resource

@export var tasks : Array[ScheduleTaskRes]
@export var receivers : Array[ReceiverRes]

var _progress := 0

func progess_tasks() -> ScheduleTaskRes:
	if _progress >= len(tasks): return null
	
	var task := tasks[_progress]
	if not task.info.has("jump_await") and task.info.has("jump"): _progress = task.info["jump"]
	else: _progress += 1
	
	return task
