class_name PatrolingResource
extends Resource

@export var waypoints : Array[Vector3]:
	set(value):
		waypoints = value
		changed.emit()

var _current_waypoint_index : int = 0

func get_current_target():
	return waypoints[_current_waypoint_index]

func waypoint_reached():
	_current_waypoint_index = (_current_waypoint_index + 1) % len(waypoints)
