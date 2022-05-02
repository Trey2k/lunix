extends CodeEdit

func _ready()->void:
	add_string_delimiter("[[", "]]")
	add_comment_delimiter("--", "", true)
	add_comment_delimiter("--[[", "]]")
	var syntaxHighlighter = CodeHighlighter.new()
	
	syntaxHighlighter.add_member_keyword_color("function", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("for", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("while", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("do", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("if", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("end", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("break", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("goto", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("true", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("false", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("return", Color.GOLD)
	syntaxHighlighter.add_member_keyword_color("local", Color.GOLD)
	
	syntaxHighlighter.set_function_color(Color.CORNFLOWER_BLUE)
	syntaxHighlighter.set_member_variable_color(Color.WHITE)
	syntaxHighlighter.set_symbol_color(Color.WHITE_SMOKE)
	syntaxHighlighter.set_number_color(Color.MEDIUM_PURPLE)
	syntaxHighlighter.add_color_region("--", "", Color.GREEN_YELLOW, true)
	syntaxHighlighter.add_color_region("--[[", "]]", Color.GREEN_YELLOW)
	syntaxHighlighter.add_color_region("\"", "\"", Color.GREEN_YELLOW)
	syntaxHighlighter.add_color_region("'", "'", Color.GREEN_YELLOW)
	syntaxHighlighter.add_color_region("[[", "]]", Color.GREEN_YELLOW)
	set_syntax_highlighter(syntaxHighlighter)
	

