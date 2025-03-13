extends Camera2D

@export_group("Nodes")
@export var player : CharacterBody2D

@export_group("Camera Settings")
@export var bottom_limit := 512
@export var top_limit := -1024
@export var left_limit := 0
@export var right_limit := 6000
@export var camera_manual_speed : float = 75
@export var camera_lerp_speed := 0.3
@export var up_panning_limit := 48
@export var down_panning_limit := 32

var is_lerping : bool = true

func _ready() -> void:
	#camera_limits()
	limit_bottom = bottom_limit
	limit_top = top_limit
	limit_left = left_limit
	limit_right = right_limit

func _physics_process(delta: float) -> void:
		
	if Input.is_action_pressed("move_camera_up") : 
		is_lerping = false
		position.x = player.position.x
		position.y -= camera_manual_speed * delta
		position.y = clamp(position.y, player.position.y - up_panning_limit, player.position.y + down_panning_limit)
		
	elif Input.is_action_pressed("move_camera_down") :
		is_lerping = false
		position.x = player.position.x 
		position.y += camera_manual_speed * delta
		position.y = clamp(position.y, player.position.y - up_panning_limit, player.position.y + down_panning_limit)
	
	else : 
		is_lerping = true
		position.x = player.position.x
	
	if is_lerping : 
		position.y = lerp(position.y, player.position.y - 16, camera_lerp_speed)
