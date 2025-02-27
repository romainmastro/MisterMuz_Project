extends Node

@export_group("Nodes")
@export var me : VMovingPlatformClass

var tween : Tween

func _ready() -> void:
	if me.direction == 0 : 
		to()
	else : 
		and_fro()

func to() : 
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(me, "position:y", me.position.y + me.distance_pixel, me.vitesse_sec).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(and_fro)
	
func and_fro() : 
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(me, "position:y", me.position.y - me.distance_pixel, me.vitesse_sec).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(to)

	
