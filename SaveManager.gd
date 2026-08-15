extends Node


var json = JSON.new()
var dictionary = {
	"Banana": "1", 
"Banna": "2",

}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func json_save():
	if FileAccess.file_exists("user://save_data.dat"):
		
		json = JSON.stringify(dictionary)
		var file = FileAccess.open("user://save_data.dat", FileAccess.WRITE)
		file.store_string(json)
	else:
		print("there is no JSON FILE")
func json_load():
	var file = FileAccess.open("user://save_data.dat", FileAccess.READ)
	var content = file.get_as_text()
	var new_content = JSON.stringify(content)
	print(new_content)
	
	
