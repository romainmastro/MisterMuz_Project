extends Camera2D

@export_group("Nodes")
@export var player : CharacterBody2D
@export var level : TileMapLayer

func _ready() -> void:
	camera_limits()


func _physics_process(_delta: float) -> void:
	center_camera_player()
	
func center_camera_player() : 
	position.x = player.position.x
	position.y = player.position.y - 16

func camera_limits() : 
	var used_rect : Rect2i = level.get_used_rect()
	
	var level_width_px = used_rect.size.x * level.tile_set.tile_size.x
	#var level_height_px = used_rect.size.y * level.tile_set.tile_size.y
	
	limit_left = 0
	# I only only one tile before 0 so must remove 2 tiles in size to display the right limit properly (1 from each side)
	limit_right = level_width_px - level.tile_set.tile_size.x *2
	limit_bottom = 512
	limit_top = -1024
	
