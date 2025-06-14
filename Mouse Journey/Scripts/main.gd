extends Node2D

@export var player : PlayerClass
@export var HUD : CanvasLayer
@export var world: Node

var current_level : Node = null

func _ready() -> void: 
	
	load_current_level()
	await get_tree().process_frame
	starting_position(current_level)
	GlobalEnemyManager.spawn()

func load_current_level() : 
	var level_scene = GlobalMenu.get_current_level()
	current_level = level_scene.instantiate()
	world.add_child(current_level)

func on_level_completed() : 
	if current_level : 
		current_level.call_deferred("queue_free")
		current_level = null

func starting_position(level) : 
	player.position = level.get_node("Sign_Start_Level").position
	GlobalPlayerStats.current_checkpoint = player.position
