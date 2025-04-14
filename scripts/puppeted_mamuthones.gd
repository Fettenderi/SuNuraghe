@tool
class_name PuppetedMamuthones
extends Creature

@export var schedule : ScheduleRes

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	super()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	super(delta)


func _start_movement() -> void:
	super()
	
	_read_schedule()


func _read_schedule() -> bool:
	if schedule == null: return false
	
	if schedule.trap_activated_receiver != null and not schedule.trap_activated_receiver.received.is_connected(_on_trap_activated):
		schedule.trap_activated_receiver.received.connect(_on_trap_activated)
	
	var task := schedule.progess_tasks()
	if task == null: return false
	
	movement_state_machine.change_state(task.get_state(), task.info, true)
	return true

func progress() -> void:
	var can_continue := _read_schedule()
	
	if can_continue: return
	movement_state_machine.update({"tasks_finished": true})

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
	movement_state_machine.change_state(schedule.trap_activated_task.get_state(), _new_task_info, true)

func _load_data(data : GStorage) -> void:
	if data.has_value(Utils.nhash(self) + &"active"):
		if data.get_value(Utils.nhash(self) + &"active"):
			if schedule != null:
				schedule.progress = int(data.get_value(Utils.nhash(self) + &"progress"))
			_start_movement()
		else: queue_free()
	else:
		if _can_start_movement:
			_start_movement()


func _save_data(data : GStorage) -> void:
	super(data)
	
	if schedule == null: return
	data.set_value(Utils.nhash(self) + &"progress", schedule.progress - 1)
