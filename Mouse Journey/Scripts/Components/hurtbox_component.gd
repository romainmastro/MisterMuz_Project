class_name ClassHurtboxComponent 
extends Node

# Register the collision to remove points [see HealthComponent for damage function]

signal damage(damage_amount : int)

@export_group("Nodes")
@export var hurtbox : Area2D
@export var grace_timer : Timer

@export_group("Settings")
@export var invincible_frame = 0.2

var is_invincible : bool = false

func _ready() -> void:
	hurtbox.area_entered.connect(area_entered)
	grace_timer.wait_time = invincible_frame
	
func area_entered(area : Area2D) : 
	grace_timer.start()
	# List the different enemies for different damage amount
	match is_invincible : 
		true : 
			return
		false : 
			if area is PitClass: 
				damage.emit(area.damage_amount)
				is_invincible = true
			
		
func _on_grace_timer_timeout() -> void:
	is_invincible = false
