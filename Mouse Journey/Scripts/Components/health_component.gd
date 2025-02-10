class_name ClassHealthComponent
extends Node

@export_group("Connected Components")
@export var hurtbox_component : ClassHurtboxComponent
var dmg : int

var is_dead : bool = false

func _ready() -> void:
	hurtbox_component.damage.connect(take_damage)

#TODO change location of this code : maybe in a Level Script
func init_health() : 
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	print("Init Health : ", GlobalPlayerStats.player_current_HP)

func take_damage(damage_amount : int) : 
	GlobalPlayerStats.player_current_HP -= damage_amount
	print("Health Update : ", GlobalPlayerStats.player_current_HP)
	
	is_dead = true if GlobalPlayerStats.player_current_HP <= 0 else false

func on_death() : 
	if is_dead : 
		get_tree().reload_current_scene()
