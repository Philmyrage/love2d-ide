extends Tree

var root

onready var tab_container = $"../VSplitContainer/TabContainer"

var project_path = Global.project_path

func _ready() -> void:
	update_dir(project_path)
	
func recursive_path(path, parent):
	var dir = open_dir(path)
	
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	
	while file_name != "":
		var file_path = path + "/" + file_name
		
		if dir.current_is_dir():
			if not file_name == "release":
				var folder_icon = load("res://assets/folder_icon.png")
				var new_dir = create_item(parent)
				new_dir.set_text(0, file_name)
				new_dir.set_icon(0, folder_icon)
				new_dir.set_icon_max_width(0, 30)
				new_dir.collapsed = true
				recursive_path(file_path, new_dir)
		else:
			var new_file = create_item(parent)
			new_file.set_text(0, file_name)
			if file_name == "main.lua":
				var icon = load("res://assets/love_icon.png")
				new_file.set_icon(0, icon)
				new_file.set_icon_max_width(0, 20)
			elif file_name.get_extension().to_lower() == "lua":
				var icon = load("res://assets/lua.png")
				new_file.set_icon(0, icon)
				new_file.set_icon_max_width(0, 30)
			elif file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "bmp", "tga", "hdr", "pic", "exr"]:
				var icon = load("res://assets/image_icon.png")
				new_file.set_icon(0, icon)
				new_file.set_icon_max_width(0, 20)
			elif file_name.get_extension().to_lower() in ["wav", "mp3", "ogg", "oga", "ogv", "mid"]:
				var icon = load("res://assets/music_icon.png")
				new_file.set_icon(0, icon)
				new_file.set_icon_max_width(0, 20)
			else:
				var icon = load("res://assets/file_icon.png")
				new_file.set_icon(0, icon)
				new_file.set_icon_max_width(0, 20)
			
			
			new_file.set_meta("path", file_path)
			new_file.set_meta("name", file_name)

			
		file_name = dir.get_next()
	dir.list_dir_end()
	


func update_dir(folder_path):
	clear()
	root = create_item()
	root.set_text(0, "root")
	recursive_path(folder_path, root)



func open_dir(path):
	var dir = Directory.new()
	if dir.open(path) != OK:
		print("Error opening directory")
		return null

	return dir



func _on_FileDialog_file_selected(path: String) -> void:
	var f = File.new()
	f.open(path, 2)
	f.store_string(tab_container.get_children()[tab_container.current_tab].text)
	tab_container.get_child(tab_container.current_tab).name = path.get_file().get_basename()
	f.close()
	update_dir(project_path)
	


func _on_TabContainer_tab_selected(tab: int) -> void:
	if not tab_container.get_children()[tab].name == "Untitled":
		var path = tab_container.get_children()[tab].get_meta("path")
		
