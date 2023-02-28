@tool
extends Node3D
class_name GrassGenerator

var PIXEL_SIZE : float = 0.01
var FLOOR_ANGLE : float = 0.524

@export var grass_texture : Texture2D
@export var grass_map : Texture2D
@export var generate : bool = false :
	set(value):
		generate = false
		
		if value:
			_clear_grass()
			_generate_grass()


func _ready():
	if not Engine.is_editor_hint():
		PIXEL_SIZE = GlobalParams.get_global_param("PIXEL_SIZE")
		FLOOR_ANGLE = GlobalParams.get_global_shader_param("FLOOR_ANGLE")
	
	if get_child_count() == 0:
		_generate_grass()


func _clear_grass():
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _generate_grass():
	if not grass_texture or not grass_map:
		return
	
	var grass_map_image : Image = grass_map.get_image()
	var rows : int = grass_map_image.get_height()
	var columns : int = grass_map_image.get_width()
	var region := Rect2i(Vector2i.ZERO, Vector2i(columns, 1))
	
	var row_length : float = grass_texture.get_width() * columns * PIXEL_SIZE
	var row_height : float = grass_texture.get_height() * PIXEL_SIZE
	var stretched_height : float = row_height / sin(FLOOR_ANGLE)
	
	var start_z_position = -rows/2.0 * stretched_height
	var start_x_position = fmod(row_length/2.0, 0.01)
	position.x = start_x_position
	
	for row in rows:
		var grass_instance := GrassInstance3D.new()
		region.position.y = row
		var row_image : Image = grass_map_image.get_region(region)
		
		grass_instance.sprite_texture = grass_texture
		grass_instance.size = Vector2(row_length, row_height)
		grass_instance.sprites_per_row = columns
		grass_instance.bitmap = ImageTexture.create_from_image(row_image)
		
		add_child(grass_instance)
		grass_instance.position.z = start_z_position + (row * stretched_height)
