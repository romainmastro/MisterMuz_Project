extends Area2D

@export var collision_area : Area2D
@export var giftbox_sprite : AnimatedSprite2D
@export var spawning_position : Marker2D
@export var hoveringObjectComponent : ClassHoveringObjectComponent
@export var collectible_deactivation_timer : Timer
var random_off_start : float

@onready var heart_scene = preload("res://Scenes/Collectibles/Collect_Heart.tscn") # 1-45
@onready var frostberry_scene = preload("res://Scenes/Collectibles/frost_berry.tscn") # 46-70 
@onready var super_frostberry_scene = preload("res://Scenes/Collectibles/super_frost_berry.tscn") # 71-90
@onready var cheese_scene = preload("res://Scenes/Collectibles/collect_cheese.tscn") # 91-100

@onready var giftbox_animator: AnimationPlayer = $GiftboxAnimator

@onready var spawning_node : Node

func _ready() -> void:
	giftbox_sprite.animation_finished.connect(_on_open_animation_finished)
	#giftbox_animator.animation_finished.connect(_on_reveal_animation_finished)
	giftbox_sprite.play("idle")
	spawning_node = get_tree().current_scene
	
	random_off_start = randf_range(0.0, 0.7)
	await get_tree().create_timer(random_off_start).timeout
	hoveringObjectComponent.float_up()


func _on_collision_area_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		if giftbox_sprite.animation != "open" : 
			giftbox_sprite.play("open")
		
func _on_open_animation_finished() : 
	if giftbox_sprite.animation == "open" : 
		giftbox_animator.play("reveal")

#func _on_reveal_animation_finished():
	#if giftbox_animator.current_animation == "reveal" : 
		#get_random_gift()

func get_random_gift() : 
	var rng = randi_range(1, 100)
	
	if rng >= 1 and rng <= 45 : 
		spawn_collectible(heart_scene)
		
	elif rng >= 46 and rng <= 70 : 
		spawn_collectible(frostberry_scene)
		
	elif rng >= 71 and rng <= 94 :
		spawn_collectible(super_frostberry_scene)
		
	elif rng >= 95 and rng <= 100 : 
		spawn_collectible(cheese_scene)

func spawn_collectible(scene : PackedScene) : 
	var collectible = scene.instantiate() as Area2D
	collectible.global_position = spawning_position.global_position
	spawning_node.add_child(collectible)
