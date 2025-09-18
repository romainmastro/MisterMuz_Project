extends Node

enum GAME_STATES{MAIN_MENU, PLAYING_GAME, LEVEL_COMPLETE_SCREEN, GAMEOVER_SCREEN, CONTINUE_SCREEN, QUIT, UNSET}
@export var current_game_state : GAME_STATES = GAME_STATES.UNSET


@onready var start_screen = preload("res://Scenes/UI/Start_Screen.tscn")
var start_screen_node : Node
@onready var congrats_screen = preload("res://Scenes/UI/congrats_screen.tscn")
var congrats_screen_node : Node
@onready var game_over_screen = preload("res://Scenes/UI/game_over_screen.tscn")
var game_over_screen_node : Node
@onready var game_states_transition = preload("res://Scenes/UI/transition.tscn")
var game_states_transition_node = Node
@onready var continue_game_screen = preload("res://Scenes/UI/continue_screen.tscn")
var continue_game_screen_node = Node

@onready var main = preload("res://Scenes/main.tscn")
var main_node : Node

var is_resuming_from_continue : bool = false


var levels_info := {
	"level1" : {
		"scene" = preload("res://Scenes/Levels/level_1_romain.tscn"),
		"rotation" = deg_to_rad(0),
		"player_mode" = "normal"
	},
	"level2" : {
		"scene" = preload("res://Scenes/Levels/level_eline.tscn"),
		"rotation" = deg_to_rad(0),
		"player_mode" = "normal"
	}, 
	"level3" : {
		"scene" = preload("res://Scenes/Levels/level_sophie.tscn"), 
		"rotation" = deg_to_rad(0),
		"player_mode" = "normal"
	}, 
	"level4" : {
		"scene" = preload("res://Scenes/TESTS/test_sledding_scene.tscn"), 
		"rotation" = deg_to_rad(15),
		"player_mode" = "sled"
	}
}

var levels := ["level1", "level2", "level3", "level4"]

@export var current_level_index : int = 3

func set_game_state(new_state : GAME_STATES) : 
	print("Changing state to:", new_state)
	if current_game_state == new_state : 
		print("WARNING : current_game_state == new State")
		return
	
	current_game_state = new_state
	print("Before Match Statement in Set Game State")
	match new_state : 
		GAME_STATES.MAIN_MENU : 
			print("Game State = main_menu")
			show_main_menu()
			
		GAME_STATES.PLAYING_GAME : 
			print("Game State = playing_game")
			if is_resuming_from_continue : 
				print("Game is Resuming")
				is_resuming_from_continue = false
				#continue_game()
			else : 
				start_new_game()
			
		GAME_STATES.LEVEL_COMPLETE_SCREEN : 
			print("Game State = level_complete_screen")
			show_congrats_screen()
			
		GAME_STATES.CONTINUE_SCREEN : 
			print("Game State = Continue?")
			show_continue_screen()
			
		GAME_STATES.GAMEOVER_SCREEN : 
			show_game_over_screen()
			print("Game State = gameover_screen")
		
		GAME_STATES.QUIT : 
			get_tree().quit()
			
		_ : 
			print("error? : game State not defined /GlobalMenu.gd")

func show_main_menu() : 
	start_screen_node = start_screen.instantiate()
	add_child(start_screen_node)
	
	if game_over_screen_node : 
		game_over_screen_node.call_deferred("queue_free")

func start_new_game() : 
	if main_node : 
		main_node.call_deferred("queue_free")
	main_node = main.instantiate()
	var game_path = get_tree().get_root().get_node("Game")
	game_path.add_child(main_node)
	
	if start_screen_node : 
		start_screen_node.call_deferred("queue_free")
		
	if congrats_screen_node : 
		congrats_screen_node.call_deferred("queue_free")
	
	if game_over_screen_node : 
		game_over_screen_node.call_deferred("queue_free")

func continue_game() -> void:
	is_resuming_from_continue = true
	var player = get_tree().current_scene.get_node("Main/PlayerV2")
	if not player:
		printerr("ERROR: Player not found in current scene.")
		return

	player.continue_game_use_a_life()
	GlobalPlayerStats.update_life_number.emit()
	# remove Continue screen from tree?
	set_game_state(GAME_STATES.PLAYING_GAME)
	get_tree().paused = false

	
func show_congrats_screen() : 
	#1 add congrats_screen
	congrats_screen_node = congrats_screen.instantiate()
	call_deferred("add_child", congrats_screen_node)
	
	#2 free main
	if main_node : 
		main_node.call_deferred("queue_free")
		
func show_game_over_screen() : 
	# 1 add game_over_screen
	game_over_screen_node = game_over_screen.instantiate()
	call_deferred("add_child", game_over_screen_node)
	
	# 2 free main
	if main_node : 
		main_node.call_deferred("queue_free")

func show_continue_screen() : 
	continue_game_screen_node = continue_game_screen.instantiate()
	call_deferred("add_child", continue_game_screen_node)

func game_transition(callback : Callable) : 
	
	# 1 instantiate the transition_node
	game_states_transition_node = game_states_transition.instantiate()
	add_child(game_states_transition_node)
	
	game_states_transition_node.set_callback(callback)
	
	# 2 get ready to play the transition animation
	var animator = game_states_transition_node.get_node("CurtainAnimator") as AnimationPlayer
	
	# 3 play close animation
	animator.play("transition")
	
	await animator.animation_finished
	if game_states_transition_node : 
		game_states_transition_node.queue_free()

func get_current_level() -> PackedScene : 
	var level_name = levels[current_level_index]
	return levels_info[level_name]["scene"]

func get_current_level_rotation() -> float:
	var level_name = levels[current_level_index]
	return levels_info[level_name]["rotation"]

func get_current_level_player_mode() -> String : 
	var level_name = levels[current_level_index]
	return levels_info[level_name]["player_mode"]

func go_next_level() : 
	current_level_index += 1

func music_fade_out(music : AudioStreamPlayer) : 
	var tween = create_tween()
	tween.tween_property(music, "volume_db",-79, 5)
	await tween.finished

func music_fade_in_and_play(music : AudioStreamPlayer) : 
	music.volume_db = -25
	music.play()
	var tween = create_tween()
	tween.tween_property(music, "volume_db",-5, 3)
	await tween.finished
