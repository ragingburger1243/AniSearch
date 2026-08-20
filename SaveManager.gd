extends Node


var json = JSON.new()

var dictionary = {}
var new_dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func json_save():
	json = JSON.stringify(dictionary)
	var file = FileAccess.open("user://save_data.dat", FileAccess.WRITE)
	file.store_string(json)
func json_load():
	if FileAccess.file_exists("user://save_data.dat"):
		var file = FileAccess.open("user://save_data.dat", FileAccess.READ)
		var content = file.get_as_text()
		new_dict = JSON.parse_string(content)
		print("NEW content: " + str(new_dict))
	else:
		print("No file found")
	
	
