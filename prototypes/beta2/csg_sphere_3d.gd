extends CSGSphere3D

@export var schedule : ScheduleRes

var _timer : Timer
var _counter := 0

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.autostart = false
	_timer.timeout.connect(_progress)
	_timer.wait_time = 1.0
	add_child(_timer, true)
	
	_read_schedule()
	_timer.start()

func _read_schedule() -> bool:
	var task := schedule.progess_tasks()
	if task == null: return false
	
	print(str(_counter) + ": " + task.state + " " + str(task.info))
	_counter += 1
	return true

func _progress():
	var can_continue := _read_schedule()
	
	if can_continue:
		_timer.start()
