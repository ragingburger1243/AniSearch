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
@onready var description_text = $"VBoxContainer4/ScrollContainer/Label (description)"
@onready var label_link = $VBoxContainer2/LinkButton 
@onready var label_genres = $"VBoxContainer2/Label (genres)"
@onready var item_list = $VBoxContainer/ItemList
var image = ""
var text_option = ""
var count_type
var results = []
func _ready() -> void:
	pass




func _on_button_pressed() -> void:
	text = lineEdit.text
	var index = option_button.selected
	text_option = option_button.get_item_text(index)
	count_type = "episodes" if text_option == "ANIME" else "chapters"
	if text == "":
		lineEdit.text = "ERROR"
		return
	else:
		if text_option == "USER":
			var main_dict = {"query": "query ($name: String) { User(name: $name) { name about avatar { large } statistics { anime { count meanScore minutesWatched } manga { count chaptersRead } } } }", "variables": {"name": text}}
			httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST,JSON.stringify(main_dict))
		else:
			count_type = "episodes" if text_option == "ANIME" else "chapters"
			var main_dict = {"query": "query ($name: String) { Page(perPage: 7) { media(search: $name, type: " + text_option + ") { title { romaji english } " + count_type + " averageScore status coverImage { large } description siteUrl genres } } }", "variables":{"name": text}}
			httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST,JSON.stringify(main_dict))

		


	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var new_body = body.get_string_from_utf8()
	
	var dict = JSON.parse_string(new_body)
	print(dict)
	item_list.clear()
	if text_option == "USER":
		var about_old = dict["data"]["User"]["about"]
		var about = ""
		if about_old != null:
			var regex = RegEx.new()
			regex.compile("<[^>]+>")
			about = regex.sub(about_old, "", true)
		else:
			label_score.text = "No bio"
			
		label_episodes.text = "USERNAME: " + str(dict["data"]["User"]["name"])
		label_score.text = "ABOUT: " +  str(about)
		label_status.text = "ANIME COUNT: " + str(dict["data"]["User"]["statistics"]["anime"]["count"])
		description_text.text = "MINUTES WATCHED: " + str(dict["data"]["User"]["statistics"]["anime"]["minutesWatched"]) + " Minutes"
		image = dict["data"]["User"]["avatar"]["large"]
		label_genres.text ="MANGA COUNT: " +  str(dict["data"]["User"]["statistics"]["manga"]["count"])

		httprequestimage.request(image)
	else:
		for item in dict["data"]["Page"]["media"]:
			var title = item["title"]["english"] if item["title"]["english"] != null else item["title"]["romaji"]
			item_list.add_item(title)
	
		results = dict["data"]["Page"]["media"]
	




func _on_http_request_2_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var img = Image.new()
	img.load_jpg_from_buffer(body)
	var texture = ImageTexture.create_from_image(img)
	texture_rect.texture = texture
	
	
	
func _on_item_list_item_selected(index: int) -> void:
	
	var desc = str(results[index]["description"])
	desc = desc.replace("<br>", "\n")
	desc = desc.replace("<i>", "")
	desc = desc.replace("</i>", "")
	desc = desc.replace("</b>", "")
	desc = desc.replace("<b>", "")
	if results[index] == null:
		lineEdit.text = "ERROR"
	else:
		if results[index]["title"]["english"] != null:
			label_title.text =  "ENGLISH TITLE: " + results[index]["title"]["english"]
		else:
			label_title.text =  "ROMAJI TITLE: " + results[index]["title"]["romaji"]
		label_episodes.text =  count_type.to_upper() + " COUNT: " + str(results[index][count_type])
		label_score.text = "SCORE:  " + str(results[index]["averageScore"])
		label_status.text = "STATUS: " + str(results[index]["status"])
		description_text.text = "DESCRIPTION: " + desc
		image = results[index]["coverImage"]["large"]
		label_genres.text = "GENRES: " + ", ".join(results[index]["genres"])
		label_link.text = "ANILIST LINK"
		label_link.uri = results[index]["siteUrl"]
		httprequestimage.request(image)


func _on_go_to_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GuessGame.tscn")
