extends enemy_class

enum STATES {IDLE, ATTACK, JUMP, RECOVER, DEAD}
@export var current_state : STATES = STATES.IDLE
@export var hitbox_idle : CollisionShape2D
@export var hitbox_slide : CollisionShape2D
@export var deadzone_idle : CollisionShape2D
@export var deadzone_slide : CollisionShape2D
@export var sliding_particles : CPUParticles2D
@export var jumping_particles : CPUParticles2D
var null_particles : CPUParticles2D = null
var has_emitted_jump_particles : bool = false

@export var gravity_component : ClassGravityComponent
@export_enum("gauche", "droite") var direction_départ = "droite"
var direction : float = 1
@export var ray : RayCast2D
var ray_offset : int = 8
@export var detection_right : RayCast2D
@export var detection_left : RayCast2D
@export var speed : float = 60.0
@export var sliding_timer : Timer
@export var sliding_time : float = 2.0

var current_direction : float = 0

func _ready() -> void:
	super()
	# init sliding timer
	sliding_timer.wait_time = sliding_time
	sliding_timer.one_shot = true
	
	# init direction
	match direction_départ : 
		"gauche" : 
			face_left()
		"droite " : 
			face_right()
			
	# init collisionShapes
	set_active_hitbox_and_deadzone(hitbox_idle, deadzone_idle)
	# init particles
	sliding_particles.global_position = $sliding_particles_marker.global_position
	jumping_particles.global_position = $jumping_particles_marker.global_position
	
func _physics_process(delta: float) -> void:
	
	gravity_component.handle_gravity(self, delta)
	
	update_state()
	
	if current_state != STATES.JUMP : 
		has_emitted_jump_particles = false
	
	handle_hitboxes()
	
	move_and_slide()
	
	# particles : 
	

func update_state() : 
	match current_state : 
		STATES.IDLE : 
			
			handle_flip()
			
			# reset variables 
			velocity.x = 0.0
			# animation
			if animated_sprite.animation != "idle" : 
				animated_sprite.play("idle")
			# transition 
			if is_player_detected() : 
				sliding_timer.start()
				current_state = STATES.JUMP
			# Particles 

			
		STATES.JUMP : 
			if animated_sprite.animation != "jump" : 
				animated_sprite.play("jump")
				
			if animated_sprite.animation == "jump":
				if animated_sprite.frame == 2 and not has_emitted_jump_particles:
					jumping_particles.emitting = true
					has_emitted_jump_particles = true
					
					
		STATES.ATTACK : 
			# animation
			if animated_sprite.animation != "slide" : 
				animated_sprite.play("slide")
		# behaviour 
			
			# move
			current_direction = direction
			velocity.x = speed * direction
			
			# disable detection
			detection_left.enabled = false
			detection_right.enabled = false
			
			# transition : 
			# wait for sliding_timer to timeout 
			# or wall or trap collisions 
			# or player stomps
			
			if is_on_wall() or not check_floor() : 
				_on_sliding_timer_timeout()
			
			# particles
			sliding_particles.emitting = true
			
			
		STATES.RECOVER : 
			
			detection_left.enabled = false
			detection_right.enabled = false
			
			# animation
			if animated_sprite.animation != "look_left_right" : 
				animated_sprite.play("look_left_right")
				
				# choose looking direction randomly : 
			
			# behaviour
			velocity.x = 0.0
			
			# transition : wait for recover animation to finish
			# particles : 

		STATES.DEAD : 
			# behaviour
			velocity = Vector2.ZERO
			handle_death()

func is_player_detected() -> bool:
	if detection_left.is_colliding():
		var colL = detection_left.get_collider()
		if colL is PlayerClass:
			return true
	if detection_right.is_colliding():
		var colR = detection_right.get_collider()
		if colR is PlayerClass:
			return true
	return false

func face_left() : 
	direction = -1
	animated_sprite.flip_h = true
	detection_left.enabled = true
	detection_right.enabled = false
	ray.position.x = -ray_offset

func face_right() : 
	direction = 1
	animated_sprite.flip_h = false
	detection_right.enabled = true
	detection_left.enabled = false
	ray.position.x = ray_offset

func handle_flip() -> void:
	if detection_left.is_colliding() and detection_left.get_collider() is PlayerClass:
		face_left()
	elif detection_right.is_colliding() and detection_right.get_collider() is PlayerClass:
		face_right()

func check_floor() -> bool : 
	if ray.is_colliding() : 
		return true
	else : 
		return false

func handle_hitboxes() : 
	match current_state : 
		STATES.IDLE, STATES.RECOVER, STATES.JUMP : 
			set_active_hitbox_and_deadzone(hitbox_idle, deadzone_idle)

		STATES.ATTACK : 
			set_active_hitbox_and_deadzone(hitbox_slide, deadzone_slide)
			
func set_active_hitbox_and_deadzone(active_hitbox : CollisionShape2D, active_deadzone : CollisionShape2D) : 
	hitbox_idle.disabled = true
	hitbox_slide.disabled = true
	active_hitbox.disabled = false
	
	deadzone_idle.disabled = true
	deadzone_slide.disabled = true
	active_deadzone.disabled = false

func deactivate_collisions() : 
	$CollisionShape_FLOOR.set_deferred("disabled", true)
	hitbox_idle.set_deferred("disabled", true)
	hitbox_slide.set_deferred("disabled", true)
	deadzone_idle.set_deferred("disabled", true)
	deadzone_slide.set_deferred("disabled", true)

func handle_death():
	if is_dead : 
		return
	is_dead = true
	deactivate_collisions()
	await do_hit_stop()

		## flash 
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.AQUA, 0.1)
	tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
	animated_sprite.play("death")

	
func _on_sliding_timer_timeout() -> void:
	current_state = STATES.RECOVER

func _on_recover_timer_timeout() -> void:
	current_state = STATES.IDLE

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death":
		death_particles.emitting = true
		animated_sprite.visible = false
		await get_tree().create_timer(0.6).timeout
		
		roll = randi_range(0, 100)
		if roll >= 1 and roll <= 20 : 
			spawn_collectible(heart_scene)
		elif roll >= 21 and roll <= 40 : 
			spawn_collectible(fruit_scene)
		elif roll >= 41 and roll <= 45 : 
			spawn_collectible(super_fruit_scene)
		else : 
			pass
		
		die()
		
	elif animated_sprite.animation == "jump" : 
		current_state = STATES.ATTACK
		
	elif animated_sprite.animation == "look_left_right" : 
		
		if current_direction == 1: # went right
			face_left()
		else: # went left
			face_right()
			
		current_state = STATES.IDLE

func _on_enemy_hitbox_class_area_entered(area: Area2D) -> void:
	if area.is_in_group("traps") : 
		_on_sliding_timer_timeout()

func _on_enemy_dead_zone_class_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player_StompBox") : 
		if not sliding_timer.is_stopped() : 
			sliding_timer.stop()
		current_state = STATES.DEAD
