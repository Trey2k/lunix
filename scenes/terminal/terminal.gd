extends Control

var input: LineEdit
var output: RichTextLabel
var scroll: ScrollContainer
var prompt: Label
var max_scroll: float

var hist: Array
var histIndex = 0
var commandExecuting = false
var getInput = false

var inputBuffer: Array

var textLock: Mutex

var builtInCommands = {}

func _ready()->void:
	input = $scrollContainer/vContainer/hContainer/lineEdit
	prompt = $scrollContainer/vContainer/hContainer/prompt
	output = $scrollContainer/vContainer/textLabel
	scroll = $scrollContainer
	
	textLock = Mutex.new()
	
	Programs.errHandler = lua_err_handler
	Programs.printFunc = add_text
	Programs.inputFunc = get_input
	scroll.get_v_scroll_bar().connect("changed", scroll_bottom)
	output.get_v_scroll_bar().connect("changed", resize_output)
	input.grab_focus()
	
func _process(_delta):
	# Only 1 message will be printed per frame
	var txt = inputBuffer.pop_front()
	if txt != null:
		output.add_text("%s\n" % txt)

func lua_err_handler(err: String)->void:
	print("Lua Error: " + err + "\n")
	add_text("Lua Error: " + err + "\n")
	
func add_builtin_command(cName: String, cmd: Callable)->void:
	builtInCommands[cName]=cmd

func _input(event: InputEvent)->void:
	if !is_visible_in_tree():
		return
	if event.is_action_pressed("enter") && getInput:
		getInput = false
	elif event.is_action_pressed("enter") && !commandExecuting:
		if !input.is_visible_in_tree():
			return
		input.hide()
		prompt.hide()
		var txt = input.text
		add_text(prompt.get_text() + " " + txt)
		hist.append(txt)
		histIndex = hist.size()
		input.clear()
		if !command(txt):
			add_text("ERROR: Unkown command")
			command_finish()
			return
		
	elif event.is_action_pressed("up") && !commandExecuting:
		if histIndex > 0:
			histIndex -= 1
		input.set_text(hist[histIndex])
	elif event.is_action_pressed("down") && !commandExecuting:
		if histIndex < hist.size()-1:
			histIndex += 1
			input.set_text(hist[histIndex])
			
func command_finish()->void:
	input.show()
	prompt.show()
	input.grab_focus()
	commandExecuting = false
		
func resize_output()->void:
	var minSize = Vector2(output.get_size().x, output.get_v_scroll_bar().get_max())
	output.minimum_size = minSize
	
func add_text(txt: String)->void:
	textLock.lock()
	inputBuffer.push_back(txt)
	textLock.unlock()
	
func set_prompt(txt: String)->void:
	prompt.set_text(txt)

func scroll_bottom()->void:
	if max_scroll != scroll.get_v_scroll_bar().max_value:
		max_scroll = scroll.get_v_scroll_bar().max_value
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func built_in_command(cmd: String, args: Array)->bool:
	if builtInCommands.has(cmd):
		commandExecuting = true
		builtInCommands[cmd].call(args)
		return true
	return false
	
func clear()->void:
	output.clear()

func command(inputText: String)->bool:
	var args = inputText.split(" ")
	if args.size() < 1:
		return false
		
	var cmd = args[0]
	args.remove_at(0)
	if built_in_command(cmd, args):
		command_finish()
		return true
	
	for program in Programs.programs:
		if program.name == cmd:
			commandExecuting = true
			program.run(args, command_finish)
			return true
	return false

func get_input()->String:
	input.clear()
	input.show()
	input.grab_focus()
	getInput=true
	while getInput:
		pass
	var txt = input.get_text()
	input.clear()
	input.hide()
	return txt

func _on_terminal_visibility_changed()->void:
	if is_visible_in_tree():
		input.grab_focus()
