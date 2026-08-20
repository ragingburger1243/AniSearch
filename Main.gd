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
@onready var item_list_favorites = $VBoxContainer5/ItemList
@onready var item_list_reccomend = $VBoxContainer6/ItemList
var image = ""
var text_option = ""
var count_type
var results = []
var results_reco = []
var reco_titles = []
var reco_data = []
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
			search_user(text)
		else:
			count_type = "episodes" if text_option == "ANIME" else "chapters"
			search_media(text, text_option, count_type)

		


	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var new_body = body.get_string_from_utf8()
	
	var dict = JSON.parse_string(new_body)
	print(dict)
	item_list.	clear()
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
		reco_data.clear()
		item_list_reccomend.clear()
		reco_titles.clear()

		for item in dict["data"]["Page"]["media"]:
			var title = item["title"]["english"] if item["title"]["english"] != null else item["title"]["romaji"]
			item_list.add_item(title)
	
			for recommendation in item["recommendations"]["nodes"]:
				if recommendation["mediaRecommendation"] != null:
					var reco_title = recommendation["mediaRecommendation"]["title"]["english"] if recommendation["mediaRecommendation"]["title"]["english"] != null else recommendation["mediaRecommendation"]["title"]["romaji"]
					if not reco_titles.has(reco_title):
						reco_titles.append(reco_title)
						reco_data.append(recommendation)
						item_list_reccomend.add_item(reco_title)
		
			
		results = dict["data"]["Page"]["media"]
		
		




func _on_http_request_2_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var img = Image.new()
	img.load_jpg_from_buffer(body)
	var texture = ImageTexture.create_from_image(img)
	texture_rect.texture = texture
	
	
	
func _on_item_list_item_selected(index: int) -> void:
	if results[index]["title"]["english"] != null:
		lineEdit.text = str(results[index]["title"]["english"])
	else:
		lineEdit.text = str(results[index]["title"]["romaji"])
	
	var desc = str(results[index]["description"])
	clean_desc(desc)
	if results[index] == null:
		lineEdit.text = "ERROR"
	else:
		label_episodes.text =  count_type.to_upper() + " COUNT: " + str(results[index][count_type])
		label_score.text = "SCORE:  " + str(results[index]["averageScore"])
		label_status.text = "STATUS: " + str(results[index]["status"])
		description_text.text = "DESCRIPTION: " + desc
		image = results[index]["coverImage"]["large"]
		label_genres.text = "GENRES: " + ", ".join(results[index]["genres"])
		label_link.text = "ANILIST LINK"
		label_link.uri = results[index]["siteUrl"]
		httprequestimage.request(image)
		label_title.text = "TITLE: " + get_title(results[index])

func _on_go_to_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GuessGame.tscn")


func _on_buttonsave_pressed() -> void:
	if "Favorites" not in SaveManager.dictionary:
		SaveManager.dictionary["Favorites"] = []
		
	SaveManager.dictionary["Favorites"].append({"name": lineEdit.text, "type": text_option})
	SaveManager.json_save()
	print("Saved!")


func _on_button_load_pressed() -> void:
	SaveManager.json_load()
	item_list_favorites.clear()
	for item in SaveManager.new_dict["Favorites"]:
		print(item)		
		item_list_favorites.add_item(item["name"])


func _on_item_list_item_save_system_selected(index: int) -> void:
	
	var save = SaveManager.new_dict["Favorites"][index]["type"]
	var selected_text = item_list_favorites.get_item_text(index)
	if save == "MANGA" or save == "ANIME":
		count_type = "episodes" if save == "ANIME" else "chapters"
		search_media(selected_text, save, count_type)
			
		
func _on_item_list_item_reco_selected(index: int) -> void:
	var results_reco_new = reco_data[index]["mediaRecommendation"]
	var Type = results_reco_new["type"]
	var anime_name
	lineEdit.text = get_title(results_reco_new)
	
	if Type == "MANGA" or Type == "ANIME":
		count_type = "episodes" if results_reco_new["type"] == "anime" else "chapters"
		search_media(anime_name, Type, count_type)




func get_title(item):
	if item["title"]["english"] != null:
		return item["title"]["english"]
	else:
		return item["title"]["romaji"]			

func clean_desc(desc):
	desc = desc.replace("<br>", "\n")
	desc = desc.replace("<i>", "")
	desc = desc.replace("</i>", "")
	desc = desc.replace("</b>", "")
	desc = desc.replace("<b>", "")

func search_media(name_media, type_media, count_type_media):
	var main_dict = {"query": "query ($name: String) { Page(perPage: 7) { media(search: $name, type: " + type_media + ") { title { romaji english } " + count_type_media + " averageScore status coverImage { large } description siteUrl genres recommendations(perPage: 7, sort: RATING_DESC) { nodes { rating mediaRecommendation { title { romaji english } coverImage { large } siteUrl  type } } } } } }", "variables":{"name": name_media}}
	httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST,JSON.stringify(main_dict))

func search_user(name_user):
	var main_dict = {"query": "query ($name: String) { User(name: $name) { name about avatar { large } statistics { anime { count meanScore minutesWatched } manga { count chaptersRead } } } }", "variables": {"name": name_user}}
	httprequest.request("https://graphql.anilist.co", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(main_dict))	
