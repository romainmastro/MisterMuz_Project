extends CanvasLayer

var callback: Callable = Callable()

func set_callback(cb: Callable) -> void:
	callback = cb

func call_transition_midpoint() -> void:
	if callback.is_valid():
		callback.call()
