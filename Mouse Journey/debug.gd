extends CanvasLayer
@onready var state: Label = $Control/VBoxContainer/State
@onready var coyote: Label = $Control/VBoxContainer/Coyote
@onready var jump_buffer: Label = $Control/VBoxContainer/JumpBuffer
@onready var velocity_x: Label = $Control/VBoxContainer/velocity_x
@onready var animation: Label = $Control/VBoxContainer/animation


@export var player : CharacterBody2D


func _physics_process(_delta: float) -> void:
	
	state.text = "State : " + player.STATE
	coyote.text = "CoyoteTime : " + str(player.coyote_timer.time_left)
	jump_buffer.text = "JumpBuffer : " + str(player.jump_buffer_time_left)
	velocity_x.text = "velocity.x : " + str(player.velocity.x)
	animation.text = "Animation : " + str(player.get_node("PlayerSprite").animation)
