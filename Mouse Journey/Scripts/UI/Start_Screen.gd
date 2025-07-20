extends Control

@export var title: Label
@export var menu: VBoxContainer 
@export var muz: AnimatedSprite2D

var target_menu_pos : Vector2
var target_title_pos : Vector2

func _ready() -> void:
	
	target_menu_pos = menu.global_position
	target_title_pos = title.global_position
	
	title.position = Vector2(48, -70)
	menu.position = Vector2(0, -80)
	muz.global_position = Vector2(8, 152 )
	
	var tween = create_tween()
	tween.tween_property(muz, "global_position", Vector2(240, 152), 3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(update_animation)
	tween.parallel().tween_property(title, "position", target_title_pos, 3).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", target_menu_pos, 3).set_trans(Tween.TRANS_ELASTIC)

func _on_start_button_pressed() -> void:
	GlobalMenu.game_transition(func() : GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.PLAYING_GAME))

func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	GlobalMenu.game_transition(func() : GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.QUIT))

func update_animation() : 
	muz.play("idle")
