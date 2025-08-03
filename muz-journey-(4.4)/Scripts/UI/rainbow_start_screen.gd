extends ColorRect

@export var speed := 0.04
var hue := 0.6111
var saturation := 0.43
var brightness := 0.85

var min_brightness := 0.27
var max_brightness := 0.84
var going_up := true 
var paused := true
@onready var timer: Timer = $Timer

func _ready() -> void:
	color = Color.from_hsv(hue, saturation, brightness)
	timer.start(2)
	
func _process(delta: float) -> void:
	if not paused : 
		update_brightness(delta)
		color = Color.from_hsv(hue, saturation, brightness)

func update_brightness(delta: float) -> void:
	#if going_up:
		#brightness += speed * delta
		#if brightness >= max_brightness:
			#brightness = max_brightness
			#going_up = false
			#paused = true
			#timer.start(3)
	#else:
	brightness -= speed * delta
	if brightness <= min_brightness:
		brightness = min_brightness
		going_up = true
		paused = true
		timer.start(2)


func _on_timer_timeout() -> void:
	paused = false
