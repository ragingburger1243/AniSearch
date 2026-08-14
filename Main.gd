extends Control

@onready var lineEdit = $VBoxContainer/LineEdit
var text = ""
@onready var httprequest = $VBoxContainer/HTTPRequest
@onready var httprequestimage = $VBoxContainer/HTTPRequest2
@onready var label_title = $"VBoxContainer2/Label (title)"
@onready var label_episodes =  $"VBoxContainer2/Label (episodes)" 
@onready var label_score = $"VBoxContainer2/Label (score)"
@onready var label_status = $"VBoxContainer2/Label (status)"
@onready var texture_rect = $VBoxContainer3/TextureRect
@onready var option_button = $OptionButton
var image = ""
var text_option = ""
var count_type
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_button_pressed() -> void:
	text = lineEdit.text
	var index = option_button.selected
	text_option = option_button.get_item_text(index)
	print(text_option)
	count_type = "episodes" if text_option == "ANIME" else "chapters"

	var main_dict = {"query": "query ($name: String) { Media(search: $name, type: " + text_option + ") { title { romaji english } " + count_type + " averageScore status coverImage { large } }  }", "variables":{"name": text}}
	httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST,JSON.stringify(main_dict))


	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var new_body = body.get_string_from_utf8()
	var dict = JSON.parse_string(new_body)
	if dict["data"]["Media"] == null:
		lineEdit.text = "ERROR"
	else:
		print(dict)
		label_title.text =  "ENGLISH TITLE: " + dict["data"]["Media"]["title"]["english"]
		label_episodes.text =  count_type.to_upper() + " COUNT: " + str(dict["data"]["Media"][count_type])
		label_score.text = "SCORE:  " + str(dict["data"]["Media"]["averageScore"])
		label_status.text = "STATUS: " + str(dict["data"]["Media"]["status"])
		image = dict["data"]["Media"]["coverImage"]["large"]
		httprequestimage.request(image)


func _on_http_request_2_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var img = Image.new()
	img.load_jpg_from_buffer(body)
	var texture = ImageTexture.create_from_image(img)
	texture_rect.texture = texture
	
	
	
	
	
