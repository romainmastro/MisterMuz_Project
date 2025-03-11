class_name ClassHealthComponent
extends Node

@export_group("Nodes")
@export var hurtbox_component : ClassHurtboxComponent
@export var player : CharacterBody2D

@export_group("Settings")
@export var time_tween_respawn : float = 0.3

var dmg : int

var is_dead : bool = false
signal just_died # sent to hurt_component

func _ready() -> void:
	hurtbox_component.damage.connect(take_damage)


func init_health() : 
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	print("Init Health : ", GlobalPlayerStats.player_current_HP)

func take_damage(damage_amount : int) :
	if not GlobalPlayerStats.player_current_HP <= 0 : 
		# Lose 1 HP
		GlobalPlayerStats.player_current_HP -= damage_amount
		print("Health Update : ", GlobalPlayerStats.player_current_HP)
		
	is_dead = true if GlobalPlayerStats.player_current_HP <= 0 else false
	
	# flash Red
	var tween = create_tween()
	tween.tween_property(player, "modulate", Color.RED, 0.1)
	tween.chain().tween_property(player, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(player, "modulate", Color.WHITE, 0.1)
	await tween.finished

func respawn_to_checkpoint(body : CharacterBody2D) :
	await get_tree().create_timer(0.7).timeout
	body.global_position = GlobalPlayerStats.current_checkpoint

func on_death() : 
	if is_dead : 
		print("Muz Died")
		just_died.emit() # see hurtbox_component
		is_dead = false
		player.velocity = Vector2.ZERO
		if GlobalPlayerStats.current_checkpoint != Vector2.ZERO : 
			respawn_to_checkpoint(player)
		else : 
			pass
		init_health()
		
