extends Control

var input: LineEdit
var output: RichTextLabel
var scroll: ScrollContainer
var prompt: Label
var max_scroll: float

var builtInCommands = {}



func _ready()->void:
	input = $scrollContainer/vContainer/hContainer/lineEdit
	prompt = $scrollContainer/vContainer/hContainer/prompt
	output = $scrollContainer/vContainer/textLabel
	scroll = $scrollContainer
	Programs.errHandler = lua_err_handler
	Programs.printFunc = add_text
	scroll.get_v_scroll_bar().connect("changed", scroll_bottom)
	output.get_v_scroll_bar().connect("changed", resize_output)
	Programs.load_all()
	input.grab_focus()

func lua_err_handler(err: String)->void:
	add_text("Lua Error: " + err + "\n")
	
func add_builtin_command(cName: String, cmd: Callable)->void:
	builtInCommands[cName]=cmd

func _input(event: InputEvent)->void:
	if event.is_action_pressed("enter"):
		if !input.is_visible_in_tree():
			return
		input.hide()
		var txt = input.text
		add_text(prompt.get_text() + txt)
		input.clear()
		if !command(txt):
			add_text("ERROR: Unkown command")
		input.show()
		input.grab_focus()
		
func resize_output()->void:
	var minSize = Vector2(output.get_size().x, output.get_v_scroll_bar().get_max())
	output.minimum_size = minSize
	
func add_text(txt: String)->void:
	output.add_text("%s\n" % txt)
	
func set_prompt(txt: String)->void:
	prompt.set_text(txt)

func scroll_bottom()->void:
	if max_scroll != scroll.get_v_scroll_bar().max_value:
		max_scroll = scroll.get_v_scroll_bar().max_value
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func built_in_command(cmd: String, args: Array)->bool:
	if cmd == "reload":
		Programs.reload()
		add_text("All programs reloaded.")
		return true
	if builtInCommands.has(cmd):
		builtInCommands[cmd].call(args)
		return true
	return false

func command(inputText: String)->bool:
	var args = inputText.split(" ")
	if args.size() < 1:
		return false
		
	var cmd = args[0]
	args.remove_at(0)
	if built_in_command(cmd, args):
		return true
	
	for program in Programs.programs:
		if program.name == cmd:
			program.lua.call_function("main", [args])
			return true
	return false

func _on_terminal_visibility_changed():
	if is_visible_in_tree():
		input.grab_focus()
