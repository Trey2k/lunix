extends Node2D

var Objects: Node2D

func _ready():
	Objects = $objects
	Programs.bindGFXFunc = bind_lua_api

func clear():
	for child in Objects.get_children():
		Objects.remove_child(child)
		child.queue_free()

func bind_lua_api(lua: Lua):
	var temp = CollisionShape2D.new()
	lua.expose_constructor(luaSprite, "Sprite")
	lua.expose_constructor(CharacterBody2D, "CharacterBody")
	lua.expose_constructor(Camera2D, "Camera")
	lua.expose_constructor(CollisionShape2D, "CollisionShape")
	lua.expose_constructor(RectangleShape2D, "RectangleShape")
	lua.expose_constructor(CircleShape2D, "CircleShape")
	var gfxLib = {
		"add_object": lua_add_object,
		"get_screen_size": lua_get_screen_size,
	}
	lua.push_variant(gfxLib, "gfx")

class luaSprite:
	extends Sprite2D
	func lua_fields():
		return ["global_position", "global_rotation", "global_scale",
			"position", "rotation", "scale", "flip_h", "centered",
			"flip_v", "frame", "frame_coords", "hframes", "offset",
			"region_rect", "region_enabled", "region_filter_clip_enabled"]

	func lua_funcs():
		return ["set_image", "apply_scale", "get_angle_to", "global_translate",
			"look_at", "move_local_x", "move_local_y", "rotate", "to_global",
			"to_local", "translate", "get_rect", "is_pixel_opaque", "connect"]

	func set_image(imgPath: String):
		if imgPath.begins_with("/"):
			imgPath = imgPath.trim_prefix("/")
		var path = "user://storage/%s" % imgPath
		texture = ImageTexture.new()
		var image = Image.new()
		image.load(path)
		texture.create_from_image(image)

func lua_get_screen_size()->Vector2:
	return get_viewport_rect().size

func lua_add_object(obj):
	Objects.add_child(obj)
