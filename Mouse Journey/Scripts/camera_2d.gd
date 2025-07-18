extends Camera2D

@export_group("Camera Input Settings")
@export var camera_manual_speed : float = 75.0
@export var camera_lerp_speed : float = 0.3
@export var up_panning_limit := 48
@export var down_panning_limit := 32

@export_group("Camera Limit Settings")
@export var bottom_limit := 2048
@export var top_limit := -1024
@export var left_limit := 0
@export var right_limit := 6000

var is_lerping := true
var vertical_offset := 0.0

#func _ready() -> void:
#
	## Set limits
	#limit_bottom = bottom_limit
	#limit_top = top_limit
	#limit_left = left_limit
	#limit_right = right_limit

func _process(delta: float) -> void:
	#var target_y_offset := 0.0
	
	if Input.is_action_pressed("move_camera_up"):
		is_lerping = false
		vertical_offset -= camera_manual_speed * delta
	elif Input.is_action_pressed("move_camera_down"):
		is_lerping = false
		vertical_offset += camera_manual_speed * delta
	else:
		is_lerping = true

	# Clamp the vertical offset relative to the player
	vertical_offset = clamp(
		vertical_offset,
		-up_panning_limit,
		down_panning_limit
	)

	# Smooth reset if not panning
	if is_lerping:
		vertical_offset = lerp(vertical_offset, 0.0, camera_lerp_speed)

	# Apply vertical offset to camera’s local Y only (X follows player naturally)
	position.y = vertical_offset
