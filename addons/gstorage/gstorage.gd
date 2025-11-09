extends Node

class_name GStorage

var save_path: String
var data: Dictionary = {}

# Конструктор через статический метод
static func create(container_name: String) -> GStorage:
	var instance = GStorage.new()
	instance.init_container(container_name)
	return instance

# Инициализация контейнера (вместо `_init()`)
func init_container(container_name: String):
	save_path = "user://" + container_name + ".json"
	load_data()

# Установить значение
func set_value(key: String, value):
	data[key] = value

# Получить значение
func get_value(key: String, default_value = null):
	return data.get(key, default_value)

func has_value(key: String, default_value = null) -> bool:
	return data.has(key)

# Удалить значение
func remove_value(key: String):
	if data.has(key):
		data.erase(key)
		save_data()

# Очистить контейнер (удаляет все данные)
func clear():
	data.clear()
	save_data()

# Сохранение в файл
func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

# Загрузка данных из файла
func load_data():
	if has_data():
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			data = JSON.parse_string(content) if content else {}
			file.close()

func copy_data(other_storage : GStorage):
	data = other_storage.data.duplicate()

func has_data() -> bool:
	return FileAccess.file_exists(save_path)

func _enter_tree():
	pass

func _exit_tree():
	pass
