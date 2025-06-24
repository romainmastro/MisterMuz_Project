extends enemy_class

enum STATES {IDLE, ATTACK, RECOVER, DEAD}
@export var current_state : STATES = STATES.IDLE

@export var gravity_component : ClassGravityComponent
@export_enum("gauche", "droite") var direction_départ = "droite"
var direction : float = 1
@export var ray : RayCast2D
@export var detection_right : RayCast2D
@export var detection_left : RayCast2D
@export var speed : float = 30.0
@export var sliding_timer : Timer
@export var sliding_time : float = 1.0

#TODO : Direction // Flip sprite // flip ray // Spawn point // Sliding timer
# is_dead // recover_timer

func _ready() -> void:
	super()
	sliding_timer.wait_time = sliding_time
	sliding_timer.one_shot = true
	
func _physics_process(delta: float) -> void:
	
	gravity_component.handle_gravity(self, delta)
	
	update_state(delta)
	
	move_and_slide()


func update_state(delta) : 
	match current_state : 
		STATES.IDLE : 
			# animation
			if animated_sprite.animation != "idle" : 
				animated_sprite.play("idle")
			# transition 
			if is_player_detected() : 
				sliding_timer.start()
				current_state = STATES.ATTACK
					
		STATES.ATTACK : 
			# animation
			if animated_sprite.animation != "slide" : 
				animated_sprite.play("slide")
		# behaviour 
			
			# move
			velocity.x = speed * delta * direction
			
			# disable detection
			detection_left.enabled = false
			detection_right.enabled = false
			
			# transition
			if not is_player_detected() : 
				current_state = STATES.IDLE
				
		STATES.RECOVER : 
			pass
			
		STATES.DEAD : 
			# behaviour
			handle_death()

func is_player_detected() -> bool: 
	var colR = detection_right.get_collider()
	var colL = detection_left.get_collider()
	
	if (colL and colL is PlayerClass) or (colR and colR is PlayerClass) :
		return true
	else :
		return false

func _on_sliding_timer_timeout() -> void:
	current_state = STATES.IDLE
