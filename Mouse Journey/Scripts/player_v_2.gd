#class_name PlayerClass
extends CharacterBody2D


@export var gravity : int = 600
@export_enum("IDLE", "RUN", "JUMP", "COYOTE", "FALL", "LAND", "SLIDE", "GLIDE") var STATE = "IDLE"
var previous_state = "IDLE"
@export var speed : float = 55
@export var direction : float = 1 # -1 = left | 0 = Idle | 1 = Right
@export var jump_strength = 210
@export var ice_accel : float = 3
@export var ice_decel : float = 5
@export var air_friction_ratio : float = 0.7

@export_group("Sprite Nodes")
@export var player_sprite : AnimatedSprite2D
@export var boots_gloves_sprite : AnimatedSprite2D
@export var snowsuit_sprite : AnimatedSprite2D
@export var snowHat_sprite : AnimatedSprite2D
@export var muffler_sprite : AnimatedSprite2D

@export_group("Timers")
@export var coyote_timer : Timer
var coyote_timer_started : bool = false
var can_jump : bool = true

var input_dir : float = 0
var previous_input_dir : float = 0

var normal_offset_hat = -2
var gliding_offset_hat := -9

func _ready() -> void:
	
	boots_gloves_sprite.visible = false
	snowsuit_sprite.visible = false 
	snowHat_sprite.visible = false
	muffler_sprite.visible = false
	
	GlobalPlayerStats.has_boots_gloves_suit_signal.connect(update_boots_gloves_visibility)
	GlobalPlayerStats.has_snowHat_signal.connect(update_snowHat_visibility)
	GlobalPlayerStats.has_muffler_signal.connect(update_muffler_visibility)
	
	snowHat_sprite.animation_changed.connect(_on_gliding_animation_changed)

func _physics_process(delta: float) -> void:
	var temp_input = running_direction()
	if temp_input != 0:
		previous_input_dir = temp_input
	input_dir = temp_input
	
	handle_gravity(delta)
	update_states()
	
	match STATE : 
		"IDLE" : 
			handle_idle_state(delta)
		"RUN" : 
			handle_run_state(delta)
		"JUMP" : 
			handle_jump_state()
		"COYOTE" : 
			handle_coyote_state(delta)
		"LAND" : 
			handle_land_state()
		"FALL" : 
			handle_fall_state()
		"GLIDE" : 
			handle_glide_state()
		"SLIDE" : 
			pass
	#
	print("COYOTE_TIME_LEFT : ", coyote_timer.time_left)

	move_and_slide()
	handle_animations()


###################################### CENTRALISED FUNCTIONS #########################
func update_states() : 
	if previous_state != STATE : 
		previous_state = STATE
		
	if is_on_floor() : 
		coyote_timer.stop()  # reset coyote timer to 0
		coyote_timer_started = false
		
		if STATE == "FALL" or STATE == "JUMP" : 
			STATE = "LAND"
		
		elif input_dir == 0 : 
			STATE = "IDLE"
		else : 
			STATE = "RUN"

	else : # is in the air
		print("COYOTE_TIME_LEFT : ", coyote_timer.time_left)
		
		if velocity.y < 0 : 
			STATE = "JUMP"
		
		elif STATE != "JUMP" and not coyote_timer_started : # Coyote Time is not running
				coyote_timer.start() # Coyote Time starts
				coyote_timer_started = true
				STATE = "COYOTE"
				
		elif coyote_timer_started and coyote_timer.time_left <= 0 : 
			STATE = "FALL"
			
			
##################################### ANIMATIONS ####################################
func handle_animations() : 
	flip_sprites()
	# RUNNING ANIMATIONS : 
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
		"JUMP" : 
			player_sprite.play("jump")
			boots_gloves_sprite.play("jump")
			snowHat_sprite.play("jump")
			snowsuit_sprite.play("jump")
			muffler_sprite.play("jump")
		"LAND" : 
			player_sprite.play("run")
			boots_gloves_sprite.play("run")
			snowHat_sprite.play("run")
			snowsuit_sprite.play("run")
			muffler_sprite.play("run")
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
	
	#print("ANIMATION : ", player_sprite.animation)


func flip_sprites() : 
	if input_dir == 0 : 
		return
	elif input_dir < 0 : 
		player_sprite.flip_h = true
		boots_gloves_sprite.flip_h = true
		snowHat_sprite.flip_h = true
		snowsuit_sprite.flip_h = true
		muffler_sprite.flip_h = true
	else : 
		player_sprite.flip_h = false
		boots_gloves_sprite.flip_h = false
		snowHat_sprite.flip_h = false
		snowsuit_sprite.flip_h = false
		muffler_sprite.flip_h = false

#######################################" STATES FUNCTIONS ###########################
func handle_idle_state(delta : float) : 
	velocity.x = lerp(velocity.x, speed * input_dir, ice_decel * delta)
	if Input.is_action_just_pressed("jump") : 
		jump()
		STATE = "JUMP"
		
func handle_run_state(delta : float) : 
	if input_dir != 0 : 
		velocity.x = lerp(velocity.x, speed * input_dir, ice_accel * delta)
	else : 
		velocity.x = lerp(velocity.x, 0.0, ice_decel * delta)

	if Input.is_action_just_pressed("jump") : 
		jump()
		STATE = "JUMP"
	
func handle_jump_state() : 
	var effective_input : float
	
	if input_dir != 0 : 
		effective_input = input_dir
	else : 
		effective_input = previous_input_dir
	
	velocity.x = speed * effective_input
	
	if velocity.y >= 0 :
		STATE = "FALL"

func handle_land_state() : 
	if abs(velocity.x) <= 5 : 
		if input_dir == 0 : 
			STATE = "IDLE"
	else : 
			STATE = "RUN"

func handle_fall_state() : 
	if input_dir != 0 :
		if previous_input_dir == - input_dir : 
			velocity.x = speed * input_dir * 1.2
		else : 
			velocity.x = speed * input_dir
		
	if is_on_floor() : 
		if input_dir == 0 : 
			STATE = "LAND"
		else : 
			STATE = "RUN"
	else : 
		if Input.is_action_pressed("glide") : 
			STATE = "GLIDE"

func handle_coyote_state(delta: float) -> void:
	if input_dir != 0:
		velocity.x = speed * input_dir
	
	if Input.is_action_just_pressed("jump"):
		jump()  

func handle_glide_state() : 
	pass
	#gravity = 50

###################################################################################

func handle_gravity(delta : float) :
	if STATE == "GLIDE" : 
		velocity.y += 50 * delta
	else : 
		velocity.y += gravity * delta
	
func running_direction() -> float : 
	return Input.get_axis("move_left", "move_right")

func handle_coyote_time() : 
	pass

func jump() : 
	if is_on_floor() or coyote_timer.time_left > 0 : 
		velocity.y = -jump_strength
		STATE = "JUMP"
	
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
