@tool
class_name PuppetedMamuthones
extends Creature

@export var schedule : ScheduleRes
@warning_ignore("unused_private_class_variable")
#@export_tool_button("PrintTransform") var _print_transform_button = _print_transform

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	super()
	
	_read_schedule()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	super(delta)


func _read_schedule() -> bool:
	if schedule == null: return false
	
	if schedule.trap_activated_receiver != null and not schedule.trap_activated_receiver.received.is_connected(_on_trap_activated):
		schedule.trap_activated_receiver.received.connect(_on_trap_activated)
	
	var task := schedule.progess_tasks()
	if task == null: return false
	
	movement_state_machine.change_state(task.state, task.info, true)
	return true

func progress() -> void:
	var can_continue := _read_schedule()
	
	if can_continue: return
	movement_state_machine.update({"tasks_finished": true})


#func _print_transform() -> void:
	#print("Position: " + str(position))

func _on_trap_activated(value : Variant):
	if schedule.trap_activated_task == null:
		print("TRAP ACTIVATED TASK NON CONVIFURATA PER " + name)
		return
	
	if not value is Vector3:
		print(name + " RICEVE UN SEGNALE CHE NON E' DI TIPO VECTOR3")
		return

	var _new_task_info := schedule.trap_activated_task.info
	
	_new_task_info["located"] = value
	
	interrupted_state = movement_state_machine.current_state.name
	movement_state_machine.change_state(schedule.trap_activated_task.state, _new_task_info, true)
