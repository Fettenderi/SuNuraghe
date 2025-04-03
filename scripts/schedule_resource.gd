class_name ScheduleRes
extends Resource

@export var tasks : Array[ScheduleTaskRes]

@export_subgroup("Trap Activated Response")
@export var trap_activated_task : ScheduleTaskRes
@export var trap_activated_receiver : ReceiverRes

var progress := 0

func progess_tasks() -> ScheduleTaskRes:
	if progress >= len(tasks): return null
	
	var task := tasks[progress]
	if task.info.has("jump"): progress = task.info["jump"]
	else: progress += 1
	
	return task

func reset_progress() -> void:
	progress = 0
