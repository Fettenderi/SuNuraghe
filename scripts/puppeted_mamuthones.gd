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


func _start_movement(additional_info : Dictionary = {}) -> void:
	super()
	
	set_deferred("visible", true)
	
	_read_schedule(additional_info)


func _read_schedule(additional_info : Dictionary = {}) -> bool:
	if schedule == null: return false
	
	if schedule.trap_activated_receiver != null and not schedule.trap_activated_receiver.received.is_connected(_on_trap_activated):
		schedule.trap_activated_receiver.received.connect(_on_trap_activated)
	
	var task := schedule.progess_tasks()
	if task == null: return false
	
	additional_info.merge(task.info)
	
	movement_state_machine.change_state(task.get_state(), additional_info, true)
	return true

func progress() -> void:
	var can_continue := _read_schedule()
	
	if can_continue: return
	movement_state_machine.update({&"tasks_finished": true})

func _on_trap_activated(value : Variant):
	if schedule.trap_activated_task == null:
		print("TRAP ACTIVATED TASK NON CONVIFURATA PER " + name)
		return
	
	if not value is Vector3:
		print(name + " RICEVE UN SEGNALE CHE NON E' DI TIPO VECTOR3")
		return

	var _new_task_info := schedule.trap_activated_task.info
	
	_new_task_info[&"located"] = value
	
	interrupted_state = movement_state_machine.current_state.name
	movement_state_machine.change_state(schedule.trap_activated_task.get_state(), _new_task_info, true)


func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self)):
		set_deferred("visible", false)
		if _can_start_movement:
			_start_movement()
		return
	
	var loaded_data : Dictionary = data.get_value(Utils.nhash(self))
	if loaded_data[&"erased"]:
		queue_free()
		return
	
	if not loaded_data[&"is_active"]:
		set_deferred("visible", false)
		return
	
	global_position = Utils.string_to_vector3(loaded_data[&"position"])
	global_rotation.y = loaded_data[&"rotation"]
	interrupted_state = loaded_data[&"interrupted_state"]
	
	var additional_info : Dictionary = {}
	if not loaded_data[&"states"].is_empty():
		if loaded_data[&"states"].has(&"wandering"):
			additional_info = loaded_data[&"states"][&"wandering"]
			
			if interrupted_state != "":
				assert(movement_state_machine.get_node(interrupted_state).has_method(&"get_save_data"))
				
				movement_state_machine.get_node(interrupted_state).load_save_data(loaded_data[&"states"][&"previous"])
		elif loaded_data[&"states"].has(&"timed"):
			additional_info = loaded_data[&"states"][&"timed"]

	if schedule != null:
		schedule.progress = loaded_data[&"schedule"][&"progress"]
	_start_movement(additional_info)

func _save_data(data : GStorage) -> void:
	if not _is_active:
		data.set_value(Utils.nhash(self), {
			&"erased" : false,
			&"is_active" : false,
		})
		return

	var schedule_data := {}
	var states_data := {}
	
	if schedule != null:
		schedule_data = {&"progress" : schedule.progress - 1} # Fishyyyyyy!
	
	if movement_state_machine.current_state.name == &"WanderingState":
		states_data[&"wandering"] = movement_state_machine.current_state.get_save_data()
		
		if interrupted_state != "":
			assert(movement_state_machine.get_node(interrupted_state).has_method(&"get_save_data"))
			
			states_data[&"previous"] = movement_state_machine.get_node(interrupted_state).get_save_data()
	elif schedule.get_current_task().info.has(&"time"):
		states_data[&"timed"] = movement_state_machine.current_state.get_timer_progress()

	data.set_value(Utils.nhash(self), {
		&"erased" : end_buffered,
		&"is_active" : _is_active,
		&"position" : global_position,
		&"rotation" : global_rotation.y,
		&"schedule" : schedule_data,
		&"states" : states_data,
		&"current_state" : movement_state_machine.current_state.name,
		&"interrupted_state" : interrupted_state,
	})
