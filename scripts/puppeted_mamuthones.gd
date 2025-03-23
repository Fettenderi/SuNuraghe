@tool
class_name PuppetedMamuthones
extends Creature

@export var schedule : ScheduleRes
@warning_ignore("unused_private_class_variable")
@export_tool_button("PrintTransform") var _print_transform_button = _print_transform

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	super()
	
	_read_schedule()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	super(delta)


func _read_schedule() -> bool:
	if schedule == null: return false
	
	var task := schedule.progess_tasks()
	if task == null: return false
	
	movement_state_machine.change_state(task.state, task.info)
	return true

func progress() -> void:
	var can_continue := _read_schedule()
	
	if can_continue: return
	movement_state_machine.update({"tasks_finished": true})


func _print_transform() -> void:
	print("Position: " + str(position))
	print("Rotation: " + str(rotation))


func get_schedule_receiver(index: int) -> ReceiverRes:
	return schedule.get_receiver(index)
