class_name PlayerClass
extends CharacterBody2D

@export_enum ("normal", "sled") var current_player_mode = "normal"

@export_group("Nodes")
@export var player_sprite : AnimatedSprite2D
@export var boots_gloves_sprite : AnimatedSprite2D
@export var snowsuit_sprite : AnimatedSprite2D
@export var snowHat_sprite : AnimatedSprite2D
@export var muffler_sprite : AnimatedSprite2D
@export var wall_ray_right : RayCast2D
@export var wall_ray_left : RayCast2D
@export var platform_checker_right : RayCast2D
@export var platform_checker_left : RayCast2D
@export var wall_ray_length : int = 6
@export var stompbox : Area2D
@export var terrain_detector : Area2D
@export var safe_behind : RayCast2D
@export var safe_under : RayCast2D
@export var safe_front : RayCast2D
var ice_patch_overlap : int = 0


#Particles
@export var marker_particles : Marker2D
@export var marker_wall_sliding : Marker2D
@export var snow_trail_particles : CPUParticles2D
@export var sliding_particles : CPUParticles2D
@export var jumping_particles : CPUParticles2D
@export var landing_particles : CPUParticles2D
@export var wall_sliding_particles : CPUParticles2D
@export var sledding_particles : CPUParticles2D
@export var sledding_brake_particles : CPUParticles2D
@export var marker_sledding_particles : Marker2D
@export var marker_sledding_brake_particles : Marker2D
var current_particles : CPUParticles2D

@export_group("General Settings")
@export var gravity : float = 600.0
# speed variables
@export var speed : float = 55.0
@export var sledding_speed_min : float = 50 # only for sledding
@export var current_speed_multiplier : float = 1.0
@export var default_speed_multiplier : float = 1.0
@export var snow_speed_multiplier : float = 1.0
@export var ice_speed_multiplier : float = 1.5
# accel variables
@export var accel : float = 6.0
@export var accel_snow_multiplier : float = 1.0
@export var accel_ice_multiplier : float = 0.1
var current_ground_multiplier : float = 1.0
var default_ground_multiplier : float = 1.0
var ground_friction : float = 1.0

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
@export var slope_jump_force : float = 200.0

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
@export var invincible_frame_sec := 0.5
@export var invincible_timer := 0.0
@export var medium_knockback_force := 70.0
@export var heavy_knockback_force := 50.0 
@export var vertical_knockback := -60.0
@export var time_knockback := 0.3
@export var time_respawn := 0.3
@export var rebound_speed := -150

var knockback_timer : float = 0.0
var knockback_velocity : Vector2 = Vector2.ZERO

var is_dead : bool = false

var is_braking : bool = false

var is_dropping_through : bool = false

var can_save_position : bool = false
var safe_position_sec : float = 0.5
var safe_positions : Array[Vector2] = []
var max_number_safe_positions : int = 5

@export_enum(
	# Ground States
	"IDLE", "RUN", "SLIDE", 
	# Airborne States
	"JUMP", "COYOTE", "WALL_JUMP","WALL_SLIDE", "SLIDE_JUMP", "FALL", "GLIDE", "JUMP_THROUGH",
	# Health/Hurt System 
	"HURT_KNOCKBACK", "HURT_RESPAWN", "DEAD", "WAIT_FOR_RESPAWN",
	# Player Sled
	"SLEDDING", "SLEDDING_JUMP", "SLEDDING_HURT", "SLEDDING_BRAKE") 

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
	
	current_player_mode = retrieve_player_mode()
	
	apply_mode_settings()
	
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
		match current_player_mode : 
			"normal" : 
				STATE = "IDLE"  # Only reset after knockback ends
			"sled" : 
				STATE = "SLEDDING"
		
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	handle_animations()
	
	handle_particles()
	
	if current_player_mode == "normal" and STATE != "SLIDE":
		flip_sprites_smooth(input_dir)


####################################### MOVEMENT SET ###########################################
func apply_mode_settings() : 
	match current_player_mode :
		"normal" : 
			STATE = "IDLE"
			speed = 55
			rebound_speed = -200
			jump_force = 210
			
		"sled" : 
			STATE = "SLEDDING"
			speed = 100
			rebound_speed = -200
			jump_force = 250
			player_sprite.offset.y -= 1
			
func retrieve_player_mode() : 
	return GlobalMenu.get_current_level_player_mode()
	
func play_animation(base_anim : String) : 
	player_sprite.play(current_player_mode + "_" + base_anim)

func process_state_machine(delta : float) : 
	if GlobalPlayerStats.player_current_HP <= 0 and STATE != "DEAD":
		print_debug("FORCE DEAD STATE")
		STATE = "DEAD"

	if STATE == "DEAD":
		if not is_dead : 
			on_death()
		return
		
	if STATE == "WAIT_FOR_RESPAWN" : 
		return
		
		
	if STATE == "HURT_KNOCKBACK":
		#deactivate collisions with Stompbox
		stompbox.monitorable = false
		stompbox.monitoring = false
		return

	if STATE == "HURT_RESPAWN":
		stompbox.monitorable = false
		stompbox.monitoring = false
		respawn_to_last_safe_position()
		return

	
	if not is_input_locked() : 
		previous_input_dir = input_dir
		
		input_dir = Input.get_axis("move_left", "move_right")
	
		previous_state = STATE
	
	if is_on_floor() and not is_input_locked(): # GROUND STATES
		match STATE : 
			"IDLE" : 
				if stompbox.monitorable == false and stompbox.monitoring == false : 
					stompbox.monitorable = true
					stompbox.monitoring = true
					
				velocity.x = lerp(velocity.x, input_dir * (speed * current_speed_multiplier), accel * current_ground_multiplier * delta)
				# TRANSITIONS
				if input_dir != 0 : 
					STATE = "RUN"
				if Input.is_action_just_pressed("jump")  : 
					jump()
					STATE = "JUMP"
				#if Input.is_action_pressed("slide") and is_on_downward_slope() : 
					#STATE = "SLIDE"
				if is_on_slide_tile() : 
					STATE = "SLIDE"
					
				if Input.is_action_pressed("down") and is_platform_droppable(): 
					drop_through()
					
			"RUN" : 
				velocity.x = lerp(velocity.x, input_dir * speed * current_speed_multiplier, accel * current_ground_multiplier * delta)
				
				# TRANSITIONS
				if input_dir == 0 : 
					STATE = "IDLE"
				if Input.is_action_just_pressed("jump"):
					jump()
					STATE = "JUMP"
				#if Input.is_action_pressed("slide") and is_on_downward_slope() : 
					#STATE = "SLIDE"
				if is_on_slide_tile() : 
					STATE = "SLIDE"
					
				if Input.is_action_pressed("down") and is_platform_droppable(): 
					drop_through()
			"SLIDE" : 
				slide(delta)
				
				if Input.is_action_just_released("slide") : 
					STATE = "RUN"
					
				if Input.is_action_just_pressed("jump") : 
					slope_jump()
					STATE = "SLIDE_JUMP"
				
			"GLIDE", "FALL", "WALL_SLIDE" : 
				if input_dir == 0 : 
					match current_player_mode : 
						"normal" : 
							STATE = "IDLE"
						"sled" : 
							STATE = "SLEDDING"
				else : 
					match current_player_mode : 
						"normal" : 
							STATE = "RUN"
						"sled" : 
							STATE = "SLEDDING"
			"SLEDDING" : 
				velocity.x = speed
				if Input.is_action_just_pressed("jump") :
					jump() 
					STATE = "JUMP"
				if Input.is_action_pressed("move_left") : 
					is_braking = true
					STATE = "SLEDDING_BRAKE"
				
			"SLEDDING_BRAKE" : 
				if is_braking : 
					velocity.x = speed/2
				if Input.is_action_just_released("move_left") : 
					is_braking = false
					STATE = "SLEDDING"
					

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
				
				if can_wall_jump() and current_player_mode == "normal": 
					STATE = "WALL_JUMP"
					wall_jump()
				
			"SLIDE_JUMP" : 
				if velocity.y >= 0 and current_player_mode == "normal": 
					is_going_up = false
					STATE = "FALL" 
				
			"COYOTE" : 
				if not coyote_timer.is_stopped() and Input.is_action_just_pressed("jump") : 
					jump()
					STATE = "JUMP"
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()
					
			"FALL", "JUMP_THROUGH" : 
				if input_dir != 0 : 
					velocity.x = speed * input_dir
					
				#TRANSITIONS
				if can_glide() : 
					STATE = "GLIDE"
					
				if Input.is_action_just_pressed("jump") : 
					buffer_jump_input()
				
				if can_wall_jump() : 
					STATE = "WALL_JUMP"
					wall_jump()
				
				if is_touching_wall() and wall_direction == input_dir and not is_dropping_through: 
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
	if GlobalPlayerStats.has_boots_gloves_suit : 
		velocity.x = wall_jump_speed * input_dir
		velocity.y = -wall_jump_force
		flip_lock_timer = flip_lock_duration
		
func is_touching_wall() : 
	return wall_ray_left.is_colliding() or wall_ray_right.is_colliding()

#### Wall slide
func wall_slide(delta : float) : 
	if not is_on_floor() : 
		velocity.y += gravity * delta * wall_slide_multiplier
		velocity.y = min(velocity.y, wall_slide_max_speed)

##### Slope Slide
#func is_on_downward_slope() -> bool : 
	#var floor_direction := get_floor_normal()
	#var facing_dir : float = sign(player_sprite.scale.x)
	#if not floor_direction.is_equal_approx(Vector2(0, -1)) : 
		#if floor_direction.x != 0 and sign(floor_direction.x) == facing_dir : 
			#if abs(rad_to_deg(get_floor_angle())) > 15 : 
				#return true
	#return false
func slide(delta: float) -> void:
	var dir = sign(get_floor_normal().x)
	
	# Only flip if the player isn't already facing the slope direction
	if sign(player_sprite.scale.x) != dir:
		player_sprite.scale.x = dir
		boots_gloves_sprite.scale.x = dir
		snowsuit_sprite.scale.x = dir
		snowHat_sprite.scale.x = dir
		muffler_sprite.scale.x = dir
	velocity.x = lerp(velocity.x, sliding_max_speed * dir, sliding_accel * delta)
	
func slope_jump() : 
	var floor_direction := get_floor_normal()
	velocity.x = sliding_max_speed * floor_direction.x
	velocity.y = -slope_jump_force

#### Glide
func glide(delta : float) : 
	velocity.x = input_dir * airborne_speed 
	velocity.y += gravity * delta * gliding_gravity_multiplier
	velocity.y = min(velocity.y, gliding_max_speed)

### drop through Platform

func is_platform_droppable() -> bool:
	var world = get_tree().current_scene.get_node_or_null("Main/WORLD")
	var tilemap = world.get_child(0).get_node("Level") as TileMapLayer
	var world_position := global_position + Vector2(0, 6)
	
	#get_tree().current_scene.get_node("Main/DebugDrawer").set_debug_point(world_position)
	
	var local_pos := tilemap.to_local(world_position)
	var map_coords := tilemap.local_to_map(local_pos)
	var tile_data = tilemap.get_cell_tile_data(map_coords)
	
	if tile_data and tile_data.get_custom_data("is_droppable"):
		return true

	return false

func drop_through() : 
	set_collision_mask_value(16, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(16, true)
	
### slidable platform

func is_on_slide_tile() -> bool:
	var world = get_tree().current_scene.get_node_or_null("Main/WORLD")
	if world == null:
		return false

	var tilemap = world.get_child(0).get_node_or_null("Level") as TileMapLayer
	if tilemap == null:
		return false

	var world_position := global_position + Vector2(0, 6)
	var local_pos := tilemap.to_local(world_position)
	var map_coords := tilemap.local_to_map(local_pos)

	var tile_data = tilemap.get_cell_tile_data(map_coords)
	if tile_data and tile_data.get_custom_data("is_slide_slope"):
		return true

	return false


######################################## HEALTH SYSTEM #######################################
func init_health() : 
	is_dead = false
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	print("Init Health : ", GlobalPlayerStats.player_current_HP)

func take_damage(damage_amount : int) :
	GlobalPlayerStats.player_current_HP = max(GlobalPlayerStats.player_current_HP - damage_amount, 0)
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
	await get_tree().create_timer(0.2).timeout
	global_position = GlobalPlayerStats.current_checkpoint
	GlobalEnemyManager.spawn()
	Engine.time_scale = 1.0

func init_player_after_respawn() : 
	if current_player_mode == "normal" : 
		STATE = "IDLE"
		
	elif current_player_mode == "sled" : 
		STATE = "SLEDDING"

func continue_game_use_a_life() : 
	velocity = Vector2.ZERO
	if GlobalPlayerStats.current_checkpoint != Vector2.ZERO : 
		respawn_to_checkpoint()
	else : 
		push_error("ERROR : There isn't any checkpoint available!!")
	init_health()
	STATE = "WAIT_FOR_RESPAWN"
	
	await get_tree().create_timer(0.2).timeout
	init_player_after_respawn()

func on_death() : 
	if is_dead : 
		return
	is_dead = true

	GlobalPlayerStats.current_lives_number -= 1
	
	if GlobalPlayerStats.current_lives_number < 0 :
		print("GAME OVER")
		GlobalMenu.game_transition(func() : GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.GAMEOVER_SCREEN))
		
	else : # Must make CONTINUE SCREEN APPEAR 
		
		
		get_tree().paused = true
		
		GlobalMenu.game_transition(func() : GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.CONTINUE_SCREEN))
		

######################################### HURT SYSTEM ########################################

func get_last_valid_safe_position() -> Vector2:
	for i in range(safe_positions.size() - 1, -1, -1):
		var pos = safe_positions[i]
		if pos == Vector2.ZERO:
			continue
		if is_respawn_position_safe(pos):
			return pos
	
	print_debug("WARNING: No valid safe position found. Falling back to checkpoint.")
	if is_respawn_position_safe(GlobalPlayerStats.current_checkpoint):
		return GlobalPlayerStats.current_checkpoint

	print_debug("WARNING: Checkpoint is not safe either. Using emergency position.")
	return Vector2(32, 32)



func respawn_to_last_safe_position() :
	var safe_position = get_last_valid_safe_position()
	await get_tree().create_timer(0.2).timeout
	velocity = Vector2.ZERO
	hide()
	global_position = safe_position
	init_player_after_respawn()
	show()

func add_safe_positions_array(pos : Vector2) : 
	safe_positions.append(pos)
	
	if safe_positions.size() > max_number_safe_positions : 
		safe_positions.pop_front()
	
func start_knockback(knockback_force: float) -> void:
	# Calculate the knockback direction.
	var kb_dir = sign(player_sprite.scale.x)
	
	knockback_velocity.x = -knockback_force * kb_dir
	knockback_velocity.y = vertical_knockback 
	
	knockback_timer = time_knockback

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if STATE == "DEAD":
		return  # No more hurt allowed if dead

	# --------------------------------------------
	# 1. SPIKES (ClassTrapRespawn)
	# Always teleport, but don't cause damage if invincible
	# --------------------------------------------
	if area is ClassTrapRespawn:
		if invincible_timer > 0:
			print("Touched spikes while invincible: teleporting only")
		else:
			print("HURT by Trap ReSpawn: lose 1 HP + teleport")
			take_damage(area.damage_amount)

			if GlobalPlayerStats.player_current_HP <= 0:
				STATE = "DEAD"
				return

			invincible_timer = invincible_frame_sec
		
		STATE = "HURT_RESPAWN"
		respawn_to_last_safe_position()
		return

	# --------------------------------------------
	# 2. Other hazards/enemies respect invincibility
	# --------------------------------------------
	if invincible_timer > 0:
		return

	if GlobalPlayerStats.player_current_HP <= 0:
		return
	
	take_damage(area.damage_amount)

	if GlobalPlayerStats.player_current_HP <= 0:
		STATE = "DEAD"
		#start_knockback(medium_knockback_force)
		return
	
	invincible_timer = invincible_frame_sec

	# --------------------------------------------
	# 3. Set appropriate hurt state
	# --------------------------------------------
	if area is ClassTrapKnockBack:
		print("HURT by Trap KnockBack")
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)

	elif area is EnemyHitboxClass:
		print("HURT by Enemy")
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)

	elif area is Snowball_proj2:
		print("HURT by Snowball")
		STATE = "HURT_KNOCKBACK"
		start_knockback(medium_knockback_force)

##################################### ANIMATIONS SYSTEM #######################################
func handle_animations() : 
	match STATE : 
		"IDLE" : 
			play_animation("idle")
			boots_gloves_sprite.play("idle")
			snowHat_sprite.play("idle")
			snowsuit_sprite.play("idle")
			muffler_sprite.play("idle")
		"RUN", "SLEDDING" : 
			play_animation("run")
			boots_gloves_sprite.play("run")
			snowHat_sprite.play("run")
			snowsuit_sprite.play("run")
			muffler_sprite.play("run")
		"JUMP", "WALL_JUMP", "SLIDE_JUMP" : 
			play_animation("jump")
			boots_gloves_sprite.play("jump")
			snowHat_sprite.play("jump")
			snowsuit_sprite.play("jump")
			muffler_sprite.play("jump")
		"COYOTE" : 
			play_animation("fall")
			boots_gloves_sprite.play("fall")
			snowHat_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
		"FALL" : 
			play_animation("fall")
			boots_gloves_sprite.play("fall")
			snowHat_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
		"WALL_SLIDE" : 
			if current_player_mode == "sled" :
				return 
			play_animation("wall_slide")
			boots_gloves_sprite.play("wall_slide")
			snowHat_sprite.play("wall_slide")
			snowsuit_sprite.play("wall_slide")
			muffler_sprite.play("wall_slide")

		"GLIDE" : 
			play_animation("glide")
			boots_gloves_sprite.play("fall")
			snowsuit_sprite.play("fall")
			muffler_sprite.play("fall")
			snowHat_sprite.play("glide")
		"SLIDE" : 
			if current_player_mode == "sled" :
				return 
			play_animation("slide")
			boots_gloves_sprite.play("slide")
			snowsuit_sprite.play("slide")
			snowHat_sprite.play("slide")
			muffler_sprite.play("slide")
			
			
		"HURT_KNOCKBACK", "HURT_RESPAWN" : 
			play_animation("hurt")
			boots_gloves_sprite.play("hurt")
			snowsuit_sprite.play("hurt")
			snowHat_sprite.play("hurt")
			muffler_sprite.play("hurt")
			
		"SLEDDING_BRAKE" : 
			if player_sprite.animation != "sled_brake" : 
				play_animation("brake")


############################# PARTICLES SYSTEM ###############################################
func handle_particles() : 
	if current_player_mode == "normal" : 
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
		
		"WALL_SLIDE" : 
			current_particles = wall_sliding_particles
			current_particles.position.x = marker_wall_sliding.position.x * player_sprite.scale.x
			current_particles.position.y = marker_wall_sliding.position.y
			current_particles.emitting = true
		
		"SLEDDING" : 
			current_particles = sledding_particles
			current_particles.global_position.x = marker_sledding_particles.global_position.x
			current_particles.global_position.y = marker_sledding_particles.global_position.y
			current_particles.emitting = true
			
		"SLEDDING_BRAKE" : 
			current_particles = sledding_brake_particles
			current_particles.global_position.x = marker_sledding_brake_particles.global_position.x
			current_particles.global_position.y = marker_sledding_brake_particles.global_position.y
			current_particles.emitting = true
			sledding_particles.emitting = true
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

func can_glide() : 
	return GlobalPlayerStats.has_snow_hat and Input.is_action_pressed("glide") and not is_touching_wall()

func update_muffler_visibility() : 
	muffler_sprite.visible = true

func _on_gliding_animation_changed() -> void:
	if snowHat_sprite.animation == "glide":
		snowHat_sprite.offset.y = gliding_offset_hat
	else:
		snowHat_sprite.offset.y = normal_offset_hat

func _on_stomp_box_area_entered(area: Area2D) -> void:
	if area is EnemyDeadZoneClass : 
		rebound()
func rebound() : 
	if velocity.y > 0 : 
		velocity.y += rebound_speed

########################### GROUND DETECTION #########################################
func _on_terrain_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ice_cover")  : 
		ice_patch_overlap += 1
		if ice_patch_overlap == 1 : 
			print("Player enter ice-patch")
			current_speed_multiplier = ice_speed_multiplier
			current_ground_multiplier = accel_ice_multiplier

func _on_terrain_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("ice_cover")  : 
		ice_patch_overlap -= 1 
		if ice_patch_overlap <= 0 : 
			ice_patch_overlap = 0
			current_speed_multiplier = default_speed_multiplier
			current_ground_multiplier = default_ground_multiplier
			print("Player exits ice-patch")


func _on_terrain_detector_body_entered(body: Node2D) -> void:
	if body is TileMapLayer and ice_patch_overlap == 0 : 
		current_ground_multiplier = accel_snow_multiplier
		current_speed_multiplier = snow_speed_multiplier
		print("Player walks snow ground")

#TODO : Correct the bug! When in invincibility frame, shouldn't record the position
func is_ground_safe() -> bool : 
	return (safe_behind.is_colliding() and 
			safe_under.is_colliding() and 
			safe_front.is_colliding())
			
			
func is_respawn_position_safe(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query := PhysicsRayQueryParameters2D.create(pos, pos + Vector2.DOWN * 8)
	query.exclude = [self]
	query.collision_mask = get_collision_mask()
	
	var result = space_state.intersect_ray(query)
	return result and result.collider and result.collider.is_in_group("ground")


func _on_safe_position_timeout() -> void:
	if GlobalPlayerStats.last_safe_position == Vector2.ZERO : 
		GlobalPlayerStats.last_safe_position = GlobalPlayerStats.current_checkpoint
		#saving the position in the array
		add_safe_positions_array(GlobalPlayerStats.last_safe_position)
	
	if invincible_timer > 0 : 
		print_debug("Skipping safe position update: invincible")
		return
	
	if not is_on_floor() : 
		return
		
	if velocity.length() == 0 : 
		return 
		
	if is_ground_safe() : 
		GlobalPlayerStats.last_safe_position = global_position
		# save positions in Array
		add_safe_positions_array(GlobalPlayerStats.last_safe_position)
