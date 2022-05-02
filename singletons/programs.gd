extends Node

class Program:
	var name: String
	var fileName: String
	var lua: Lua
	var thread: Thread
	func include(fileName: String):
		var absPath = "user://storage"
		if !fileName.begins_with("/"):
			absPath += "/"
		absPath += fileName
		lua.do_file(absPath)
	
var programs: Array[Program]
var errHandler: Callable
var printFunc: Callable
var inputFunc: Callable
var bindGFXFunc: Callable

enum {MODE_TERM, MODE_GFX}
var changeMode: Callable

func load_all()->void:
	var dir = Directory.new()
	if dir.open("user://storage") == OK:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() || !fileName.ends_with(".lua"):
				fileName = dir.get_next()
				continue
			add_program(fileName)
			fileName = dir.get_next()

func reload()->void:
	programs.clear()
	load_all()

func add_program(fileName: String)->void:
	var program = Program.new()
	program.name = fileName.replace(".lua", "").to_lower()
	program.fileName = "user://storage/%s" % fileName
	program.lua = Lua.new()
	setupAPI(program)
	program.lua.do_file(program.fileName)
	if program.lua.function_exists("main"):
		programs.append(program)
		if program.lua.function_exists("init"):
			program.lua.call_function("init", [])

func setupAPI(program: Program)->void:
	program.lua.bind_libs(["base", "string", "table", "debug", "utf8"])
	if errHandler.is_valid():
		program.lua.set_error_handler(errHandler)
	if !printFunc.is_valid() || !inputFunc.is_valid() || !changeMode.is_valid() || !bindGFXFunc.is_valid():
		print("ERROR invalid print, changeMode, bindGFX or input func")
		return
	bindGFXFunc.call(program.lua)
	program.lua.push_variant(program.include, "include")
	program.lua.expose_constructor(Thread, "Thread")
	program.lua.expose_constructor(Mutex,  "Mutex")
	var luaOS = {
		"get_input": inputFunc,
		"print": printFunc,
		"change_mode": changeMode,
	}
	program.lua.push_variant(luaOS, "os")

func lua_change_mode(mode: String)->void:
	match mode:
		"term":
			changeMode.call(MODE_TERM)
		"gfx":
			changeMode.call(MODE_GFX)

func _exit_tree():
	for program in programs:
		if program.thread != null && program.thread.is_alive():
			program.thread.wait_to_finish()
