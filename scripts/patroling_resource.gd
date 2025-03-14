class_name PatrolingResource
extends Resource

@export var waypoints : Array[Vector3]:
	set(value):
		waypoints = value
		changed.emit()

var current_waypoint_index : int = 0

func has_targets():
	return len(waypoints) > 0

func get_current_target():
	return waypoints[current_waypoint_index]

func waypoint_reached():
	current_waypoint_index = (current_waypoint_index + 1) % len(waypoints)
