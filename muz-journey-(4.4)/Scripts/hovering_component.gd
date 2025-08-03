class_name ClassHoveringObjectComponent
extends Node

@export_group("Settings")
@export var floating_distance : float = 5
@export var floating_speed : float = 0.8

@export_group("Nodes")
@export var object : Area2D

func float_up() : 
	var tween = create_tween()
	tween.tween_property(object, "position:y", object.position.y - floating_distance, floating_speed).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(float_down)

func float_down() : 
	var tween = create_tween()
	tween.tween_property(object, "position:y", object.position.y + floating_distance, floating_speed).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(float_up)
