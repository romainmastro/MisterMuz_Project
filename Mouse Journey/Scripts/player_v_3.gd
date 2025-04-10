class_name PlayerClass
extends CharacterBody2D

@export_group("Sprite Nodes")
@export var player_sprite : AnimatedSprite2D
@export var boots_gloves_sprite : AnimatedSprite2D
@export var snowsuit_sprite : AnimatedSprite2D
@export var snowHat_sprite : AnimatedSprite2D
@export var muffler_sprite : AnimatedSprite2D
@export var wall_ray_right : RayCast2D
@export var wall_ray_left : RayCast2D
@export var wall_ray_length : int = 6
#Particles
@export var marker_particles : Marker2D
@export var snow_trail_particles : CPUParticles2D
@export var sliding_particles : CPUParticles2D
@export var jumping_particles : CPUParticles2D
@export var landing_particles : CPUParticles2D
var current_particles : CPUParticles2D

@export_group("General Settings")
@export var gravity : float = 600.0
@export var speed : float = 55.0
@export var ice_accel : float = 6.0
@export var ice_decel : float = 3.0

@export_group("Health System")
@export var time_tween_respawn : float = 0.3

@export_group("Gliding Settings")
@export var gliding_force : float = 9.7
@export var gliding_gravity_multiplier : float = 0.05
@export var gliding_max_speed : float = 30.0
@export var airborne_speed : float = 45.0

@export_group("Wall_slide Settings")
@export var wall_slide_multiplier : float = 0.05
@export var wall_slide_max_speed : float = 50

@export_group("Sliding Settings")
@export var sliding_max_speed : float = 150.0
@export var sliding_accel : float = 10
@export var slope_jump_force : float = 300.0

@export_group("Jump Settings")
@export var jump_force : int = 210
@export var coyote_timer : Timer
@export var coyote_grace_sec : float = 0.1
@export var jump_buffer_grace_sec : float = 0.1
var jump_buffer_time_left : float = 0.0

@export_group("Wall Jump Settings")
@export var wall_jump_force : int = 200
@export var wall_jump_speed : float = 65.0
var wall_direction : int = 0

@export_group("Animations")
@export var flip_lock_duration : float = 0.1
var flip_lock_timer : float = 0.0
var normal_offset_hat = -2
var gliding_offset_hat := -9

@export_group("Hurt and Knockback")
@export var invincible_frame_sec := 1
@export var invincible_timer := 0.0
@export var medium_knockback_force := 70.0
@export var heavy_knockback_force := 50.0 
@export var vertical_knockback := -60.0
@export var time_knockback := 0.3
@export var time_respawn := 0.3
@export var rebound_speed := -300

var knockback_timer : float = 0.0
var knockback_velocity : Vector2 = Vector2.ZERO


@export_enum(
	# Ground States
	"IDLE", "RUN", "SLIDE", 
	# Airborne States
	"JUMP", "COYOTE", "WALL_JUMP","WALL_SLIDE", "SLIDE_JUMP", "FALL", "GLIDE",
	# Health/Hurt System 
	"HURT_KNOCKBACK", "HURT_RESPAWN", "DEAD") 

var STATE = "IDLE"

var previous_state : String = "IDLE"

var input_dir : float
var previous_input_dir : float
var temp_input : float
var is_going_up : bool = false
var was_on_floor : bool = false

var tween_KB : Tween
var knockback_started : bool = false

############################################ READY #################################################
func _ready() -> void:
	
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	print("Init Health : ", GlobalPlayerStats.player_current_HP)
	
	boots_gloves_sprite.visible = false
	snowsuit_sprite.visible = false 
	snowHat_sprite.visible = false
	muffler_sprite.visible = false
	
	GlobalPlayerStats.has_boots_gloves_suit_signal.connect(update_boots_gloves_visibility)
	GlobalPlayerStats.has_snowHat_signal.connect(update_snowHat_visibility)
	GlobalPlayerStats.has_muffler_signal.connect(update_muffler_visibility)
	
	snowHat_sprite.animation_changed.connect(_on_gliding_animation_changed)
	
	coyote_timer.wait_time = coyote_grace_sec
	
	wall_ray_left.target_position.x = -wall_ray_length
	wall_ray_right.target_position.x = wall_ray_length
	
	# Particles
	current_particles = snow_trail_particles
	
	
####################################### PHYSICS PROCESS ###########################################
func _physics_process(delta: float) -> void:
	handle_gravity(delta)
		
	# Coyote time
	handle_coyote_time()
	
	handle_jump_buffer_timer(delta)
		
	handle_buffer_time()
	
	handle_flip_lock_timer(delta)
		
	handle_invincible_timer(delta)
	
	# Process knockback effect if active.
	if knockback_timer > 0:
		knockback_timer -= delta
		# Override the player's velocity with the knockback velocity.
		velocity = knockback_velocity
		# Optionally, you could gradually damp the knockback velocity here.
	else:
		# Run your normal state machine if not in knockback.
		process_state_machine(delta)
		
	if knockback_timer <= 0 and STATE == "HURT_KNOCKBACK":
		print("reset STATE to IDLE after HURT")
		STATE = "IDLE"  # Only reset after knockback ends
		
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	handle_animations()
	
	handle_particles()
	
	flip_sprites_smooth(input_dir)


####################################### ________________ ###########################################
func process_state_machine(delta : float) : 

	if STATE == "DEAD":
		print("STATE is now DEAD")
		on_death()
		return

	if STATE == "HURT_KNOCKBACK":
		#knockback(medium_knockback_force)
		return

	if STATE == "HURT_RESPAWN":
		respawn_to_last_safe_position()
		return

	
	if not is_input_locked() : 
		previous_input_dir = input_dir
		
		input_dir = Input.get_axis("move_left", "move_right")
	
		previous_state = STATE
	
	if is_on_floor() and not is_input_locked(): # GROUND STATES
		match STATE : 
			"IDLE" : 
				velocity.x = lerp(velocity.x, input_dir * speed, ice_decel * delta)
				# TRANSITIONS
				if input_dir != 0 : 
					STATE = "RUN"
				if Input.is_action_just_pressed("jump") : 
					jump()
					STATE = "JUMP"
				if Input.is_action_pressed("slide") and is_on_downward_slope() : 
					STATE = "SLIDE"
					
			"RUN" : 
				velocity.x = lerp(velocity.x, input_dir * speed, ice_accel * delta)
				
				# TRANSITIONS
				if input_dir == 0 : 
					STATE = "IDLE"
				if Input.is_action_just_pressed("jump"): 
					jump()
					STATE = "JUMP"
				if Input.is_action_pressed("slide") and is_on_downward_slope() : 
					STATE = "SLIDE"
			
			"SLIDE" : 
				slide(delta)
				
				if Input.is_action_just_released("slide") : 
					STATE = "RUN"
					
				if Input.is_action_just_pressed("jump") : 
					slope_jump()
					STATE = "SLIDE_JUMP"
					
				if not is_on_downward_slope() : 
					STATE = "RUN"
				
			"GLIDE", "FALL", "WALL_SLIDE" : 
				if input_dir == 0 : 
					STATE = "IDLE"
				else : 
					STATE = "RUN"

	elif not is_on_floor() and not is_input_locked(): # AIRBORNE STATES
		match STATE : 
			"IDLE" : 
				# TRANSITIONS
				if not is_on_floor() : 
					STATE = "FALL"
			"RUN" : 
				if not coyote_timer.is_stopped() : 
					STATE = "COYOTE"
					
			"JUMP" : 
				# Variable Jump Height
				if !is_on_floor() and  Input.is_action_just_released("jump") and is_going_up : 
					velocity.y = 0
				
				#TRANSITIONS
				if velocity.y >= 0 : 
					is_going_up = false
					STATE = "FALL"
				else : 
					is_going_up = true
				
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()
				
			"SLIDE_JUMP" : 
				if velocity.y >= 0 : 
					is_going_up = false
					STATE = "FALL" 
				
			"COYOTE" : 
				if not coyote_timer.is_stopped() and Input.is_action_just_pressed("jump") : 
					jump()
					STATE = "JUMP"
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()
					
			"FALL" : 
				if input_dir != 0 : 
					velocity.x = speed * input_dir
					
				#TRANSITIONS
				if Input.is_action_pressed("glide") and not is_touching_wall() :
					if GlobalPlayerStats.has_snow_hat :  
						STATE = "GLIDE"
					
				if Input.is_action_just_pressed("jump") : 
					buffer_jump_input()
				
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()
				
				if is_touching_wall() and wall_direction == input_dir : 
					STATE = "WALL_SLIDE"
					
			"WALL_JUMP" : 
				# TRANSITIONS
				if velocity.y >= 0 : 
					STATE = "FALL"
					
			"WALL_SLIDE" :
				wall_slide(delta)
				
				# TRANSITIONS 
				if not is_touching_wall() : 
					STATE = "FALL"
					
				if input_dir != wall_direction : 
					STATE = "FALL"
					
			"GLIDE" :
				glide(delta)
				
				#TRANSITIONS
				if Input.is_action_just_released("glide") : 
					STATE = "FALL"
					
				if Input.is_action_just_pressed("jump") : 
					buffer_jump_input()
				
				if is_touching_wall() : 
					STATE = "WALL_SLIDE"
				
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()

	###############################################
func handle_gravity(delta : float) : 
	if STATE not in ["GLIDE", "WALL_SLIDE"] : 
		velocity.y += gravity * delta
func flip_sprites_smooth(direction: float):
	if direction == 0:
		return

	var target_scale_x = sign(direction)
	
	smooth_flip(player_sprite, target_scale_x)
	smooth_flip(boots_gloves_sprite, target_scale_x)
	smooth_flip(snowHat_sprite, target_scale_x)
	smooth_flip(snowsuit_sprite, target_scale_x)
	smooth_flip(muffler_sprite, target_scale_x)
func smooth_flip(sprite: Node2D, target_scale_x: float):
	if sprite.scale.x != target_scale_x:
		var tween := create_tween()
		tween.tween_property(sprite, "scale:x", target_scale_x, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func handle_flip_lock_timer(delta : float) :
		if flip_lock_timer > 0 : 
			flip_lock_timer -= delta
func handle_invincible_timer(delta : float) : 
	if invincible_timer > 0 : 
		invincible_timer -= delta
	else : 
		invincible_timer = 0
	
	if invincible_timer > 0:
		self.modulate = Color(1, 1, 1, 0.3)  # transparent
	else:
		self.modulate = Color(1, 1, 1, 1)    # normal
func handle_jump_buffer_timer(delta) : 
	if jump_buffer_time_left > 0 :
		jump_buffer_time_left -= delta 
func is_input_locked() -> bool : 
	return true if STATE in ["HURT_KNOCKBACK", "HURT_RESPAWN", "DEAD"] else false

####Jump
func jump() : 
	if input_dir != 0 : 
		velocity.x = speed * input_dir
	velocity.y = -jump_force
func handle_coyote_time() -> void:
	if was_on_floor and not is_on_floor() and STATE == "RUN":
		coyote_timer.start()
		STATE = "COYOTE"
	elif STATE == "COYOTE" and coyote_timer.is_stopped():
		STATE = "FALL"
func handle_buffer_time() -> void : 
	if is_on_floor() and jump_buffer_time_left > 0 : 
		jump()
		STATE = "JUMP"
		jump_buffer_time_left = 0.0
func buffer_jump_input() : 
	if not is_on_floor() and STATE not in ["JUMP"] :
		jump_buffer_time_left = jump_buffer_grace_sec

#### Wall_Jump
func can_wall_jump() -> bool : 
	if wall_ray_left.is_colliding() : 
		wall_direction = -1
		
	elif wall_ray_right.is_colliding() : 
		wall_direction = 1
		
	if wall_direction != 0 : 
		var is_opposite_input_pressed : bool = false
		var jump_pressed : bool = false
		
		is_opposite_input_pressed = true if sign(input_dir) == -wall_direction else false 
		jump_pressed = Input.is_action_just_pressed("jump") or jump_buffer_time_left > 0 
		
		if jump_pressed and is_opposite_input_pressed and is_touching_wall() : 
			jump_buffer_time_left = 0
			return true
			
	return false
func wall_jump() : 
	velocity.x = wall_jump_speed * input_dir
	velocity.y = -wall_jump_force
	flip_lock_timer = flip_lock_duration
func is_touching_wall() : 
	return wall_ray_left.is_colliding() or wall_ray_right.is_colliding()

#### Wall slide
func wall_slide(delta : float) : 
	velocity.y += gravity * delta * wall_slide_multiplier
	velocity.y = min(velocity.y, wall_slide_max_speed)
	print(velocity.y)

#### Slope Slide
func is_on_downward_slope() -> bool : 
	var floor_direction := get_floor_normal()
	var facing_dir : float = sign(player_sprite.scale.x)
	if not floor_direction.is_equal_approx(Vector2(0, -1)) : 
		if floor_direction.x != 0 and sign(floor_direction.x) == facing_dir : 
			if abs(rad_to_deg(get_floor_angle())) > 30 : 
				return true
	return false
func slide(delta : float) : 
	velocity.x = lerp(velocity.x, sliding_max_speed * sign(get_floor_normal().x), sliding_accel * delta)
func slope_jump() : 
	var floor_direction := get_floor_normal()
	velocity.x = sliding_max_speed * floor_direction.x
	velocity.y = -slope_jump_force

#### Glide
func glide(delta : float) : 
	velocity.x = input_dir * airborne_speed 
	velocity.y += gravity * delta * gliding_gravity_multiplier
	velocity.y = min(velocity.y, gliding_max_speed)

######################################## HEALTH SYSTEM #######################################
func init_health() : 
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	print("Init Health : ", GlobalPlayerStats.player_current_HP)

func take_damage(damage_amount : int) :
	GlobalPlayerStats.player_current_HP -= damage_amount
	print("HP reduced to ", GlobalPlayerStats.player_current_HP)

	if GlobalPlayerStats.player_current_HP <= 0:
		print("PLAYER IS DEAD!")
		STATE = "DEAD"

	# flash Red
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.2)
	await tween.finished

func respawn_to_checkpoint() :
	await get_tree().create_timer(0.7).timeout
	global_position = GlobalPlayerStats.current_checkpoint

func on_death() : 

	print("Muz Died")
	
	velocity = Vector2.ZERO
	if GlobalPlayerStats.current_checkpoint != Vector2.ZERO : 
		respawn_to_checkpoint()
	else : 
		push_error("ERROR : There isn't any checkpoint available!!")
	init_health()
	STATE = "IDLE"

######################################### HURT SYSTEM ########################################
func respawn_to_last_safe_position() :
	var safe_position = GlobalPlayerStats.last_safe_position
	await get_tree().create_timer(0.5).timeout
	velocity = Vector2.ZERO
	hide()
	global_position = safe_position
	show()

func start_knockback(knockback_force: float) -> void:
	# Calculate the knockback direction.
	var kb_dir = sign(player_sprite.scale.x)
	
	knockback_velocity.x = -knockback_force * kb_dir
	knockback_velocity.y = vertical_knockback 
	
	knockback_timer = time_knockback

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if invincible_timer > 0 : 
		return
	
	if GlobalPlayerStats.player_current_HP <= 0 : return
	
	take_damage(area.damage_amount)
	
	if STATE == "DEAD":
		start_knockback(medium_knockback_force)
		return  # Exit early if we've just died
	
	invincible_timer = invincible_frame_sec
	
	if area is ClassTrapRespawn: 
		STATE = "HURT_RESPAWN"
		return
		# hurt animation
		
	elif area is ClassTrapKnockBack : 
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)
		return
		
	elif area is EnemyHitboxClass : 
		print("HURT by Enemy")
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)
		return
			
	elif area is Snowball_proj2 : 
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)
		return

func body_entered(body : Node2D) : 
		if not invincible_timer > 0 : 

			if body is TrapSnowballClass:
				STATE = "HURT_KNOCKBACK"
				take_damage(body.damage_amount)
				velocity = Vector2.ZERO

##################################### ANIMATIONS SYSTEM #######################################
func handle_animations() : 
	match STATE : 
		"IDLE" : 
			player_sprite.play("idle")
			boots_gloves_sprite.play("idle")
			snowHat_sprite.play("idle")
			snowsuit_sprite.play("idle")
			muffler_sprite.play("idle")
		"RUN" : 
			player_sprite.play("run")
			boots_gloves_sprite.play("run")
			snowHat_sprite.play("run")
			snowsuit_sprite.play("run")
			muffler_sprite.play("run")
		"JUMP", "WALL_JUMP", "SLIDE_JUMP" : 
			player_sprite.play("jump")
			boots_gloves_sprite.play("jump")
			snowHat_sprite.play("jump")
			snowsuit_sprite.play("jump")
			muffler_sprite.play("jump")
		"COYOTE" : 
			player_sprite.play("fall")
			boots_gloves_sprite.play("fall")
			snowHat_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
		"FALL" : 
			player_sprite.play("fall")
			boots_gloves_sprite.play("fall")
			snowHat_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
		"GLIDE" : 
			player_sprite.play("glide")
			boots_gloves_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
			snowHat_sprite.play("glide")
		"SLIDE" : 
			player_sprite.play("slide")
			boots_gloves_sprite.play("slide")
			snowsuit_sprite.play("slide")
			snowHat_sprite.play("slide")
			muffler_sprite.play("slide")
			
		"HURT_KNOCKBACK", "HURT_RESPAWN" : 
			player_sprite.play("hurt")
			boots_gloves_sprite.play("hurt")
			snowsuit_sprite.play("hurt")
			snowHat_sprite.play("hurt")
			muffler_sprite.play("hurt")

############################# PARTICLES SYSTEM ###############################################
func handle_particles() : 
	current_particles.direction.x *= input_dir
	
	match STATE : 
		"RUN" : 
			current_particles = snow_trail_particles
			current_particles.global_position.x = marker_particles.global_position.x - 5 * input_dir
			current_particles.global_position.y = marker_particles.global_position.y

			if abs(velocity.x) > 20 : 
				current_particles.emitting = true
		"JUMP" : 
			current_particles = jumping_particles
			current_particles.global_position.x = marker_particles.global_position.x
			current_particles.global_position.y = marker_particles.global_position.y
			current_particles.emitting = true
			
		"SLIDE" : 
			current_particles = sliding_particles
			current_particles.global_position.x = marker_particles.global_position.x
			current_particles.global_position.y = marker_particles.global_position.y
			current_particles.emitting = true
			
		_ : 
			current_particles.emitting = false
			
	if was_on_floor == false and is_on_floor() == true : 
		current_particles = landing_particles
		current_particles.global_position.x = marker_particles.global_position.x
		current_particles.global_position.y = marker_particles.global_position.y
		current_particles.emitting = true

########################### VISIBILITY and ANIMATIONS #########################################

func update_boots_gloves_visibility() : 
	boots_gloves_sprite.visible = true
	snowsuit_sprite.visible = true

func update_snowHat_visibility() : 
	snowHat_sprite.visible = true
	
func update_muffler_visibility() : 
	muffler_sprite.visible = true

func _on_gliding_animation_changed() -> void:
	if snowHat_sprite.animation == "glide":
		snowHat_sprite.offset.y = gliding_offset_hat
	else:
		snowHat_sprite.offset.y = normal_offset_hat


func _on_stomp_box_area_entered(area: Area2D) -> void:
	if area is EnemyDeadZoneClass : 
				print("enemy dead so REBOUND")
				rebound()
func rebound() : 
	if velocity.y > 0 : 
		velocity.y += rebound_speed
