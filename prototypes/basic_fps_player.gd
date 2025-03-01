extends BasicPlayer

var _speed := SPEED

func _input(event):
	super(event)
	
	# Cambiare head bobbing in base alla velocità, più lento ti muovi meno si muove e vice versa
	if event.is_action_pressed("sprint"):
		set_noise(true)
		SPEED = _speed + 3.0
	elif event.is_action_released("sprint"):
		set_noise(false)
		SPEED = _speed
	elif event.is_action_pressed("cover"):
		SPEED = _speed - 3.0
		head_start_pos.y = head_start_pos.y - 0.6
	elif event.is_action_released("cover"):
		SPEED = _speed
		head_start_pos.y = head_start_pos.y + 0.6
	
