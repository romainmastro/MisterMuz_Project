extends ClassTrapKnockBack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_group("Settings")
@export var falling_speed : float = 150

var current_speed : float = 0

func fall() : # is called in the animation player thanks to a call method track
	current_speed = falling_speed

func _physics_process(delta: float) -> void:
	position.y += current_speed * delta
	
func _on_detector_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		animation_player.play("shake")

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		call_deferred("queue_free")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")
