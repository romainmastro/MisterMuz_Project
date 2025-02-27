extends Node

@export_group("Nodes")
@export var me : AnimatableBody2D

var point_to_reach_bottom : int = 0
var point_to_reach_top : int = 0
var real_pos : Vector2 = Vector2.ZERO
var moving_down : bool = true

func _ready() -> void:
	real_pos = me.position
	point_to_reach_bottom = real_pos.y + me.moving_distance_pixel # position + 32
	point_to_reach_top = real_pos.y - me.moving_distance_pixel # position -32

func _process(delta: float) -> void:
	if moving_down : 
		to(delta)
		if me.position.y >= point_to_reach_bottom : 
			moving_down = false
	else : 
		and_fro(delta)
		if me.position.y <= point_to_reach_top : 
			moving_down = true

func to(delta : float) : 
	real_pos.y += me.speed * delta
	me.position = real_pos
	
func and_fro(delta : float) : 
	real_pos.y -= me.speed * delta
	me.position = real_pos
	
