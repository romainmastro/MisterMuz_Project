extends CharacterBody2D

@export var gravity : float = 600.0
@export var damage_amount := 1
var my_velocity : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	velocity.y += gravity * delta

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer : 
		queue_free()
