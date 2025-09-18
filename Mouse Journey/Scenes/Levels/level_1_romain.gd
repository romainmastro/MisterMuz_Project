extends Node2D

@export var music_level1 : AudioStreamPlayer

@export var sections_node : Node2D
@export var SECTIONS : Array[Area2D] = []
var player : PlayerClass = null
var player_camera : Camera2D = null

var current_section_number : int = 0

func _ready() -> void:
	GlobalMenu.music_fade_in_and_play(music_level1)

func start_section_system():
	populate_sections()
	connect_entered_section_signals()
	

func populate_sections() : 
	SECTIONS.clear()
	for child in sections_node.get_children() : 
		SECTIONS.append(child)
		

func connect_entered_section_signals():
	for section in SECTIONS:
			section.body_entered.connect(_on_section_entered.bind(section))

func _on_section_entered(body : Node2D, section : Area2D) : 
	if body is PlayerClass :
		var index = SECTIONS.find(section)
		
		if current_section_number == 0 : 
			update_camera_limits()
		
		if index != current_section_number : 
			current_section_number = index
			update_camera_limits()
			

func update_camera_limits():
	var section := SECTIONS[current_section_number]
	var shape_node := section.get_node("CollisionShape2D")
	var shape := shape_node.shape as RectangleShape2D
	if shape == null:
		return

	var global_center = shape_node.global_position
	var half_extents = shape.extents

	player_camera.limit_left = int(global_center.x - half_extents.x)
	player_camera.limit_right = int(global_center.x + half_extents.x)
	player_camera.limit_top = int(global_center.y - half_extents.y)
	player_camera.limit_bottom = int(global_center.y + half_extents.y)
	
	
