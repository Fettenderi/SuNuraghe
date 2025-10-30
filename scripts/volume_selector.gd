extends VBoxContainer

@export var title : String
@export_enum("Master") var bus : String

@onready var _title: Label = %Title
@onready var _volume_visualizer: Label = %VolumeVisualizer
@onready var _decrease: Button = %Decrease
@onready var _increase: Button = %Increase

var _volume := 10:
	set(value):
		_volume = value
		_volume_visualizer.text = str(_volume)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), _volume / 10.0)
		for fmod_bus : FmodBus in FmodServer.get_all_buses():
			fmod_bus.set_volume(_volume / 10.0)

func _ready() -> void:
	_title.text = tr(title)
	LevelStats.config_saving.connect(_on_saving)
	LevelStats.config_loading.connect(_on_loading)

func _on_decrease_button_up() -> void:
	_volume = max(_volume - 1, 0)

func _on_increase_button_up() -> void:
	_volume = min(_volume + 1, 10)

func set_enabled(value : bool):
	_decrease.set_deferred("disabled", not value)
	_increase.set_deferred("disabled", not value)

func _on_saving(data : GStorage) -> void:
	data.set_value(bus + &"_volume", _volume)

func _on_loading(data : GStorage) -> void:
	if data.has_value(bus + &"_volume"):
		_volume = data.get_value(bus + &"_volume")

#func _on_focus_entered():
	#_decrease.grab_focus()
