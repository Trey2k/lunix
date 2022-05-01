extends Control

var Terminal: Control
var Editor: Control

var currentDir: Directory

func _ready():
	Terminal = $Terminal
	Editor = $codeEditor
	currentDir = Directory.new()
	if currentDir.open("user://storage") != OK:
		make_storage()
	
	Terminal.add_builtin_command("edit", edit_command)
	Terminal.add_builtin_command("mkdir", mkdir_command)
	Terminal.add_builtin_command("ls", ls_command)
	Terminal.add_builtin_command("cd", cd_command)
	Terminal.add_builtin_command("rm", rm_command)
	Terminal.set_prompt("%s >" % currentDir.get_current_dir().replace("user://storage", ""))
	Editor.connect("editor_closed", Terminal.show)

func edit_command(args: Array)->void:
	if args.size() < 1:
		Terminal.add_text("ERROR: No file provided.")
	if !Editor.open_file(args[0], currentDir.get_current_dir()):
		Terminal.add_text("ERROR: Unable to open file")
		return
	Terminal.hide()
	
func mkdir_command(args: Array)->void:
	if args.size() < 1:
		Terminal.add_text("ERROR: No directory name provided.")
	var dirName: String = args[0]
	var dir = Directory.new()
	if dirName.begins_with("/"):
		dirName = dirName.trim_prefix("/")
		dir.open("user://storage")
	else:
		dir.open(currentDir.get_current_dir())
	if currentDir.make_dir(dirName) != OK:
		Terminal.add_text("ERROR: Unable to make directory '%s'." % dirName)
	
func ls_command(args: Array)->void:
	var dir: Directory
	if args.size() < 1:
		dir = currentDir
	else:
		dir = Directory.new()
		dir.open(currentDir.get_current_dir())
		dir.change_dir(args[0])
		
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		if fileName.begins_with("."):
			fileName = dir.get_next()
			continue
		if dir.current_is_dir():
			Terminal.add_text("%s/" % fileName)
		else:
			Terminal.add_text(fileName)
		fileName = dir.get_next()
	dir.list_dir_end()

func cd_command(args: Array)->void:
	if args.size() < 1:
		Terminal.add_text("ERROR: No directory name provided.")
	if currentDir.change_dir(args[0]) != OK:
		Terminal.add_text("ERROR: Unable to open directory '%s'" % args[0])
	if currentDir.get_current_dir() == "user://":
		currentDir.change_dir("storage")
	Terminal.set_prompt("%s >" % currentDir.get_current_dir().replace("user://storage", ""))	

func rm_command(args: Array)->void:
	if args.size() < 1:
		Terminal.add_text("ERROR: No directory/file name provided.")
	if currentDir.remove(args[0]) != OK:
		Terminal.add_text("ERROR: Unable to remove file %s" % args[0])
	Programs.reload()
	
func make_storage()->void:
	currentDir.open("user://")
	currentDir.make_dir("storage")
	currentDir.change_dir("storage")
