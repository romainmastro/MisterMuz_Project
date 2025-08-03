extends ClassTrapKnockBack

@export var animated_sprite : AnimatedSprite2D
@export var hitbox : CollisionShape2D

@export var cooldown_timer : Timer
@export var cooldown_time : float = 1.5

@export var windup_timer : Timer
@export var windup_time : float = 0.8

@export var eruption_timer : Timer
@export var eruption_time : float = 1.5

@export var geyser_particles : CPUParticles2D

enum STATES{IDLE, WINDUP, ERUPTION} 
var current_state : STATES

func _ready() -> void:
	cooldown_timer.wait_time = cooldown_time
	eruption_timer.wait_time = eruption_time
	windup_timer.wait_time = windup_time
	
	current_state = STATES.IDLE

func _physics_process(_delta: float) -> void:
	match current_state : 
		STATES.IDLE : 
			#animation
			if animated_sprite.animation != "idle" : 
				animated_sprite.play("idle")
				
			#visual
			if geyser_particles.emitting : 
				geyser_particles.emitting = false
				
			#hitbox
			if not hitbox.disabled : 
				deactivate_hitbox()
			
			# Start Timer
			if cooldown_timer.is_stopped() : 
				cooldown_timer.start()
		
		STATES.WINDUP :
			#animation 
			animated_sprite.play("windup")
			
			# Start Timer
			if windup_timer.is_stopped() : 
				windup_timer.start()
				
		STATES.ERUPTION : 
			#animation
			animated_sprite.play("idle")
			
			#Visual
			if not geyser_particles.emitting : 
				geyser_particles.emitting = true
				
			#hitbox
			if hitbox.disabled : 
				activate_hitbox()
			
			# Start Timer
			if eruption_timer.is_stopped() : 
				eruption_timer.start()

func deactivate_hitbox()  : 
	if hitbox.disabled == false : 
		hitbox.disabled = true

func activate_hitbox(): 
	if hitbox.disabled == true : 
		hitbox.disabled = false

func _on_cooldown_timer_timeout() -> void:
	current_state = STATES.WINDUP

func _on_windup_timer_timeout() -> void:
	current_state = STATES.ERUPTION

func _on_eruption_timer_timeout() -> void:
	current_state = STATES.IDLE
