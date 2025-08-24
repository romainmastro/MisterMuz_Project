extends Area2D

@export var tutorial_panel : PackedScene

@export var press_info_jump : Label

var can_show : bool = false
var node_path : Node

var tut : Control


func _ready() -> void:
	press_info_jump.visible = false
	node_path = get_tree().current_scene.get_node_or_null("Main/HUD")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and can_show : 
		
		get_tree().paused = true
		tut = tutorial_panel.instantiate()
		node_path.add_child(tut)
		can_show = false
		
	elif event.is_action_pressed("ui_cancel") and not can_show and tut : 
		get_tree().paused = false
		if tut and is_instance_valid(tut): 
			tut.call_deferred("queue_free")
		tut = null



func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		toggle_visibility()
		can_show = true
		

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerClass : 
		toggle_visibility()
		can_show = false


func toggle_visibility() : 
	press_info_jump.visible = not press_info_jump.visible
	
