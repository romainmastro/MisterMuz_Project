extends Node2D

@onready var button: Area2D = $Button
@onready var sprite_button_on: Sprite2D = $Button/Sprite_button_on
@onready var sprite_button_off: Sprite2D = $Button/Sprite_button_off
@onready var platform: StaticBody2D = $Platform
@onready var collision_shape_2d: CollisionShape2D = $Platform/CollisionShape2D
@onready var platform_sprite: Sprite2D = $Platform/Sprite2D
@onready var platform_animator: AnimationPlayer = $Platform/PlatformAnimator

var is_activated : bool = false

func _ready() -> void:
	sprite_button_off.visible = true
	sprite_button_on.visible = false
	
	button.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body : Node2D) : 
	if body is PlayerClass and not is_activated : 
		is_activated = true
		open_the_trap_door()

func open_the_trap_door() : 
	sprite_button_off.visible = false
	sprite_button_on.visible = true
	platform_animator.play("open_trap")
