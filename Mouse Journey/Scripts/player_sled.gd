#extends PlayerClass
#
## TODO : 
#
#@export var sledding_particles : CPUParticles2D
#@export var sledding_particles_marker : Marker2D
#
#@export var jump_buffer_timer : Timer
#@export var jump_buffer_time : float = 0.2
#var jump_is_buffered : bool = false
#
#@export var coyote_time : float = 0.2
#var jump_is_coyoted : bool = false
#
#
#enum STATES{SLEDDING, JUMPING, FALLING, DEAD, HURT_KNOCKBACK, HURT_RESPAWN}
#@export var current_state = STATES.SLEDDING
#
#func _ready() -> void:
	## init timers
	#jump_buffer_timer.wait_time = jump_buffer_time
	#jump_buffer_timer.one_shot = true
	#
	#coyote_timer.wait_time = coyote_time
	#coyote_timer.one_shot = true
	#
	## init particles
	#sledding_particles.global_position = sledding_particles_marker.global_position
	#
	## init values
	#speed = 100
	#rebound_speed = 200
	#jump_force = 250
	#
	#
#func _physics_process(delta: float) -> void:
	## COYOTE TIME : 
	#if not is_on_floor() and not coyote_timer.is_stopped() : 
		#pass
	#if not is_on_floor() and coyote_timer.is_stopped() : 
		#coyote_timer.start()
		#jump_is_coyoted = true
	#
	#handle_gravity(delta)
#
	#update_states()
#
	#move_and_slide()
#
#func update_states() : 
	#if current_state == STATES.DEAD:
		#print("STATE is now DEAD")
		#on_death()
		#return
#
	#if current_state == STATES.HURT_KNOCKBACK:
		##deactivate collisions with Stompbox
		#stompbox.monitorable = false
		#stompbox.monitoring = false
		#return
#
	#if current_state == STATES.HURT_RESPAWN:
		#stompbox.monitorable = false
		#stompbox.monitoring = false
		#respawn_to_last_safe_position()
		#return
		#
	#if is_on_floor() : 
		#match current_state : 
			#STATES.SLEDDING : 
				## animation
				#player_sprite.play("sledding")
				## behaviour
				#velocity.x = speed
				## transition
				#if Input.is_action_just_pressed("jump") or jump_is_buffered or (Input.is_action_just_pressed("jump") and jump_is_coyoted) : 
					#jump() 
					#current_state = STATES.JUMPING
					#coyote_timer.stop()
				## particles
				#sledding_particles.emitting = true
			#STATES.JUMPING, STATES.FALLING : 
				#current_state = STATES.SLEDDING
#
	#if not is_on_floor() : 
		#match  current_state : 
			#STATES.JUMPING : 
				## animation
				#player_sprite.play("jumping")
				##transitions
				#if velocity.y >= 0 : 
					#current_state = STATES.FALLING
#
			#STATES.FALLING : 				
				#if Input.is_action_just_pressed("jump") : 
					#jump_buffer_timer.start()
					#jump_is_buffered = true
				#
			#STATES.DEAD : 
				#print("state : dead")
#
#func jump() : 
	#velocity.y = -jump_force
	#
#func rebound() : 
	#if velocity.y > 0 : 
		#velocity.y += rebound_speed
#
#func _on_jump_buffer_timer_timeout() -> void:
	#jump_is_buffered = false
#
#func _on_coyote_timer_timeout() -> void:
	#jump_is_coyoted = false
#
#func _on_stomp_box_area_entered(area: Area2D) -> void:
	#if area is EnemyDeadZoneClass : 
		#rebound()
