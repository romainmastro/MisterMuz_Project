extends enemy_class

@export var snow_mole : CharacterBody2D
@export var snow_mole_anim_sprite : AnimatedSprite2D
@export var MOUNDS : Array[Sprite2D]
var current_mound_index : int = 0
@export var switch_mound_timer : Timer
@export var underground_timer : Timer
@export var attacking_cooldown : Timer
@export var ray_right : RayCast2D
@export var ray_left : RayCast2D

@export_enum("IDLING", "SWITCHING_MOUND","TRAVELING_UNDERGROUND", "ATTACKING", "DEAD") var current_state = "IDLING"
@export var gravity : float = 600.0
@export var hop_force : float = -80.0
@export var attacking_force : float = -200.0
@export var switch_mound_wait_time : float = 1
@export var underground_timer_wait_time : float = 1
@export var death_pop_up_offset : float = -12.0

var hop_initiated : bool = false
var has_left_floor : bool = false
var has_attacked_once : bool = false
var has_left_floor_to_attack : bool = false
var snow_mole_collision_enabled : bool = true

var snow_mole_scale : Vector2 = Vector2(0.8, 0.8)

func _ready() -> void:
	start_idle()
	snow_mole.global_position = MOUNDS[0].global_position 
	snow_mole.scale = snow_mole_scale
	
	switch_mound_wait_time = randf_range(0.8, 1.8)
	switch_mound_timer.wait_time = switch_mound_wait_time
	
	underground_timer_wait_time = randf_range(0.6, 1.2)
	underground_timer.wait_time = underground_timer_wait_time

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	flip_snow_mole()
	
	match current_state : 
		
		"IDLING" : 
			hop_initiated = false
			has_left_floor = false
			if not snow_mole_collision_enabled : 
				enable_snow_mole_collision()
			
			#animation
			start_idle()
			
			if attacking_cooldown.is_stopped() and switch_mound_timer.is_stopped() : 
				switch_mound_timer.start()
				
			# transition
			if is_player_detected() and attacking_cooldown.is_stopped() : 
				switch_mound_timer.stop()
				# transition
				current_state = "ATTACKING"
		
		"SWITCHING_MOUND" :
			if not hop_initiated:
				snow_mole_anim_sprite.stop()
				snow_mole.velocity.y = hop_force
				hop_initiated = true
			
			if hop_initiated and not snow_mole.is_on_floor() : 
				has_left_floor = true
			
			# transition
			if snow_mole.is_on_floor() and has_left_floor : 
				snow_mole.visible = false
				current_state = "TRAVELING_UNDERGROUND"
				underground_timer.start()
				
		"TRAVELING_UNDERGROUND" : 
			# Do nothing : just wait for underground_timer to timeout
			if snow_mole_collision_enabled : 
				disable_snow_mole_collision()
		
		"ATTACKING" : 
			if not has_attacked_once : 
				snow_mole.velocity.y = attacking_force
				has_attacked_once = true
			# animation
				snow_mole_anim_sprite.play("attack")
			if has_attacked_once and not snow_mole.is_on_floor() : 
				has_left_floor_to_attack = true
			# transition
			if has_left_floor_to_attack and snow_mole.is_on_floor() : 
				attacking_cooldown.start()
				current_state = "IDLING"
		
		"DEAD" : 
			print("State : Dead")
			handle_death()
			
	if not is_dead : 
		snow_mole.move_and_slide()

func apply_gravity(delta : float) : 
	snow_mole.velocity.y += gravity * delta

func switch_mounds() : 
	current_mound_index = (current_mound_index + 1) % MOUNDS.size()
	snow_mole.global_position = MOUNDS[current_mound_index].global_position
		
func start_idle() : 
	if snow_mole_anim_sprite.animation != "idle" or not snow_mole_anim_sprite.is_playing():
		snow_mole_anim_sprite.play("idle")

func is_player_detected() -> bool : 
	return ray_left.is_colliding() or ray_right.is_colliding()
	
func flip_snow_mole() : 
	if ray_left.is_colliding():
		snow_mole.scale.x = -1
	elif ray_right.is_colliding():
		snow_mole.scale.x = 1


func _on_switch_mounds_timer_timeout() -> void:
	current_state = "SWITCHING_MOUND"
	
func _on_underground_timer_timeout() -> void:
	switch_mounds()
	snow_mole.velocity = Vector2.ZERO
	snow_mole.visible = true
	current_state = "IDLING"

func _on_attacking_cooldown_timeout() -> void:
	has_attacked_once = false
	has_left_floor_to_attack = false

func handle_death():
	if is_dead : 
		return
	is_dead = true
	
	await do_hit_stop()
	
	if snow_mole_collision_enabled : 
		disable_snow_mole_collision()

	## flash Red
	# Slight pop up before death animation
	var tween = create_tween()
	var start_pos = snow_mole.position
	var end_pos = start_pos + Vector2(0, death_pop_up_offset)

	tween.tween_property(snow_mole, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# After moving up, flash + play death animation
	tween.chain().tween_callback(func ():
		var flash = create_tween()
		flash.tween_property(self, "modulate", Color.AQUA, 0.1)
		flash.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
		flash.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
		snow_mole_anim_sprite.play("death")
	)
	
	snow_mole_anim_sprite.play("death")

func disable_snow_mole_collision() : 
	snow_mole_collision_enabled = false
	
	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	deadzone.set_deferred("monitorable", false)
	deadzone.set_deferred("monitoring", false)
	
func enable_snow_mole_collision() :
	snow_mole_collision_enabled = true
	
	collision_shape.set_deferred("disabled", false)
	hitbox.set_deferred("monitorable", true)
	hitbox.set_deferred("monitoring", true)
	deadzone.set_deferred("monitorable", true)
	deadzone.set_deferred("monitoring", true)


func _on_enemy_dead_zone_class_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player_StompBox") : 
		current_state = "DEAD"
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if snow_mole_anim_sprite.animation == "death" : 
		$snow_mole/DeathParticles.emitting = true
		snow_mole_anim_sprite.visible = false
		await get_tree().create_timer(0.6).timeout
		queue_free()
