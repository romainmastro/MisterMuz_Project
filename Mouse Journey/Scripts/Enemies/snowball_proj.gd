class_name Snowball_proj2
extends Area2D

var speed : float = 30.0
var direction : int = 1
@export var damage_amount : int = 1

func _physics_process(delta: float) -> void:
	global_position.x += speed * delta * direction


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer : 
		queue_free()
	elif body is PlayerClass : 
		queue_free()
