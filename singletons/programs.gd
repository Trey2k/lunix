extends Node

class Program:
	var name: String
	var fileName: String
	var lua: Lua
	
var programs: Array[Program]
var errHandler: Callable
var printFunc: Callable

func load_all()->void:
	var dir = Directory.new()
	if dir.open("user://storage") == OK:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() || !fileName.contains(".lua"):
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
	setupAPI(program.lua)
	program.lua.do_file(program.fileName)
	if program.lua.function_exists("main"):
		programs.append(program)
		if program.lua.function_exists("init"):
			program.lua.call_function("init", [])

func setupAPI(lua: Lua)->void:
	lua.bind_libs(["base", "string", "table", "io", "os", "debug", "utf8"])
	if errHandler.is_valid():
		lua.set_error_handler(errHandler)
	if printFunc.is_valid():
		lua.push_variant(printFunc, "print")
