extends Label

var player : PlayerClass

func _ready() -> void:
	player = get_parent().get_parent() as PlayerClass

func _physics_process(_delta: float) -> void:
	text = player.STATE
