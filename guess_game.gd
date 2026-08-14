extends Control

@onready var line_edit = $VBoxContainer/LineEdit
@onready var button = $VBoxContainer/Button
@onready var httprequest = $HTTPRequest
@onready var option_button = $VBoxContainer/OptionButton
@onready var label = $ScrollContainer/Label
@onready var start_button = $VBoxContainer/Button2
var text
var count_type
var text_option = ""
var RANDOM_NUMBER
var anime_name
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	text = line_edit.text
	if text.to_lower() == anime_name.to_lower():
		line_edit.text = "GOOD JOB YOU GOT IT RIGHT"
	else:
		line_edit.text = "YOU GOT IT WRONG"
	
	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var new_body = body.get_string_from_utf8()
	var dict = JSON.parse_string(new_body)
	var desc = str(dict["data"]["Page"]["media"][0]["description"])
	if dict["data"]["Page"]["media"][0]["title"]["english"] != null:
		anime_name = str(dict["data"]["Page"]["media"][0]["title"]["english"])
	else:
		anime_name = str(dict["data"]["Page"]["media"][0]["title"]["romaji"])
	desc = desc.replace("<br>", "\n")
	desc = desc.replace("<i>", "")
	desc = desc.replace("</i>", "")
	label.text = "DESCRIPTION: " + str(desc)
	


func _on_button_2_pressed() -> void:
	line_edit.clear()
	RANDOM_NUMBER = str(randi() % 100 + 1)
	var index = option_button.selected
	text_option = option_button.get_item_text(index)
	count_type = "episodes" if text_option == "ANIME" else "chapters"
	print(text)
	var main_dict = {"query": "{ Page(perPage: 1, page: "+ RANDOM_NUMBER+") { media(sort: POPULARITY_DESC, type: " + text_option + ") { title { romaji english } " + count_type + " averageScore status coverImage { large } description siteUrl genres } } }"}
	httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST,JSON.stringify(main_dict))


func _on_gobackbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
