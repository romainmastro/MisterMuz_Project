extends Node2D

var bright_colors : Array[Color] = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.LIME,
	Color.AQUA,
	Color.CYAN,
	Color.SKY_BLUE,
	Color.DEEP_SKY_BLUE,
	Color.DODGER_BLUE,
	Color.MAGENTA,
	Color.FUCHSIA,
	Color.HOT_PINK,
	Color.TOMATO,
	Color.GOLD,
	Color.LAWN_GREEN
]

var door_array : Array[Node]
var i : int = 0

func _ready() -> void: 
	# Check if there are doors in the level
	door_array = get_children()
	if door_array.is_empty() : 
		return
	# Shuffle the array
	bright_colors.shuffle()
	
	# Color the specific nodes
	for child in door_array : 
		child.get_node("Platform/Sprite2D/color_platform_rect").color = bright_colors[i]
		child.get_node("Button/Sprite_button_off/color_button_off_rect").color = bright_colors[i]
		child.get_node("Button/Sprite_button_on/color_button_on_rect").color = bright_colors[i]
		i += 1
		i = i % bright_colors.size()
		

	
