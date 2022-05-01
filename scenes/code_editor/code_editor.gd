extends Control

var editor: CodeEdit
var fileNameEdit: LineEdit

var dir: String

signal editor_closed

func _ready():
	fileNameEdit = $container/VBoxContainer/HBoxContainer/LineEdit
	editor = $container/VBoxContainer/CodeEdit
	hide()

func open_file(fName: String, fDir: String)->bool:
	dir = fDir
	var file = File.new()
	print(dir+"/"+fName)
	var err = file.open(dir+"/"+fName, File.READ)
	if err != ERR_FILE_NOT_FOUND && err != OK:
		return false
	if file.is_open():
		editor.set_text(file.get_as_text())
		file.close()
	fileNameEdit.set_text(fName)
	show()
	return true
	

func _on_exit_button_up():
	editor.set_text("")
	hide()
	emit_signal("editor_closed")

func _on_save_button_up():
	var content = editor.get_text()
	if !content.ends_with("\n"):
		content += "\n"
	var fName=fileNameEdit.get_text()
	var file = File.new()
	file.open(dir+"/"+fName, File.WRITE)
	file.store_string(content)
	file.close()
	Programs.reload()
