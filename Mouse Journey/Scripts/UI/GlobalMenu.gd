extends Node

enum GAME_STATES{MAIN_MENU, PLAYING_GAME, LEVEL_COMPLETE_SCREEN, GAMEOVER_SCREEN, QUIT, UNSET}
var current_game_state : GAME_STATES = GAME_STATES.UNSET


@onready var start_screen = preload("res://Scenes/UI/Start_Screen.tscn")
var start_screen_node : Node
@onready var congrats_screen = preload("res://Scenes/UI/congrats_screen.tscn")
var congrats_screen_node : Node
@onready var game_over_screen = preload("res://Scenes/UI/game_over_screen.tscn")
var game_over_screen_node : Node
@onready var game_states_transition = preload("res://Scenes/UI/transition.tscn")
var game_states_transition_node = Node

@onready var main = preload("res://Scenes/main.tscn")
var main_node : Node

var levels : Array[PackedScene] = [
	preload("res://Scenes/Levels/level_1_romain.tscn"),
	preload("res://Scenes/Levels/level_eline.tscn"),
	preload("res://Scenes/Levels/level_sophie.tscn"),
	]
var current_level_index : int = 0

func set_game_state(new_state : GAME_STATES) : 
	print("Changing state to:", new_state)
	if current_game_state == new_state : 
		return
	
	current_game_state = new_state
	
	match new_state : 
		GAME_STATES.MAIN_MENU : 
			print("Game State = main_menu")
			show_main_menu()
			
		GAME_STATES.PLAYING_GAME : 
			print("Game State = playing_game")
			start_game()
			
		GAME_STATES.LEVEL_COMPLETE_SCREEN : 
			print("Game State = level_complete_screen")
			show_congrats_screen()
			
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

func start_game() : 
	main_node = main.instantiate()
	var game_path = get_tree().get_root().get_node("Game")
	game_path.add_child(main_node)
	
	if start_screen_node : 
		start_screen_node.call_deferred("queue_free")
		
	if congrats_screen_node : 
		congrats_screen_node.call_deferred("queue_free")
	
	if game_over_screen_node : 
		game_over_screen_node.call_deferred("queue_free")
		
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
	return levels[current_level_index]

func go_next_level() : 
	current_level_index += 1
