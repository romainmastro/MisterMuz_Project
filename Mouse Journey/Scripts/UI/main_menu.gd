extends Control

@onready var title: Label = $Title
@onready var menu: VBoxContainer = $Menu
@onready var muz: AnimatedSprite2D = $Muz


func _ready() -> void:
	title.position = Vector2(48, -20)
	menu.position = Vector2(0, -50)
	muz.position = Vector2(8, 120 )
	
	var tween = create_tween()
	tween.tween_property(muz, "position", Vector2(240, 120), 2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(update_animation)
	tween.parallel().tween_property(title, "position", Vector2(48, 24), 3).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", Vector2(0, 72), 3).set_trans(Tween.TRANS_ELASTIC)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func update_animation() : 
	muz.play("idle")
