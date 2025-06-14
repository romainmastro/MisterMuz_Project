extends Control

@onready var title: Label = $Title
@onready var menu: VBoxContainer = $Menu
@onready var muz: AnimatedSprite2D = $Muz

var target_menu_pos : Vector2
var target_title_pos : Vector2


func _ready() -> void:
	
	target_menu_pos = menu.global_position
	target_title_pos = title.global_position
	
	title.position = Vector2(48, -70)
	menu.position = Vector2(0, -80)
	muz.position = Vector2(8, 160 )
	
	var tween = create_tween()
	tween.tween_property(muz, "position", Vector2(240, 160), 3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(update_animation)
	tween.parallel().tween_property(title, "position", target_title_pos, 3).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", target_menu_pos, 3).set_trans(Tween.TRANS_ELASTIC)

func _on_start_button_pressed() -> void:
	GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.PLAYING_GAME)

func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func update_animation() : 
	muz.play("idle")
