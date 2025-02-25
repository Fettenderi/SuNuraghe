class_name PhysiscsResource
extends Resource

## Provvides common parametes to customize movement of various nodes.
##
## [PhysiscsResource] can be used to customize parameters regarding movement metrics. Use [method setup] method to properly initialize all the parameters.

@export_subgroup("Jump")

## Sets the max jump height in pixels.
@export var jump_height : float

## Sets the time needed to reach [member jump_height] in seconds.
@export var jump_time_to_peak : float

## Sets the time needed to reach the floor from [member jump_height] in seconds.
@export var jump_time_to_floor : float

## Sets the maximum horizontal reach of a jump in pixels. 
@export var jump_reach : float

@export_subgroup("Movement")

## Sets the time needed to reach [member max_speed] in seconds.
@export var time_to_max_speed : float

## Sets the time needed to reach [code]0.0[/code] speed from [member max_speed] in seconds.
@export var time_to_zero_speed : float

## Is the velocity to apply when jumping.
var jump_velocity : float

## Is the gravity acceleration to apply when on the rising phase of the jump.
var ascending_gravity : float

## Is the gravity acceleration to apply when on the falling phase.
var descending_gravity : float

## Is the maximum speed reachable.
var max_speed : float

## Is the acceleration to apply when an horizontal input is pressed.
var acceleration : float

## Is the acceleration to apply when no horizontal input is pressed.
var deceleration : float

var _inverse_jump_time_to_peak : float
var _inverse_jump_time_to_floor : float

## Needs to be called to initialize all the parameters.
func setup() -> void:
	_inverse_jump_time_to_peak = 1.0 / jump_time_to_peak
	_inverse_jump_time_to_floor = 1.0 / jump_time_to_floor
	jump_velocity = - 2.0 * jump_height * _inverse_jump_time_to_peak
	ascending_gravity = 2.0 * jump_height * _inverse_jump_time_to_peak * _inverse_jump_time_to_peak
	descending_gravity = 2.0 * jump_height * _inverse_jump_time_to_floor * _inverse_jump_time_to_floor
	max_speed = 0.5 * jump_reach * _inverse_jump_time_to_peak
	acceleration = max_speed / time_to_max_speed
	deceleration = max_speed / time_to_zero_speed
