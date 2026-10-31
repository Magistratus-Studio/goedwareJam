extends Node

@export var label: Label
@export var cicleTimer: Timer

func _process(_delta: float) -> void:
	label.text = str("%.2f" % cicleTimer.time_left)
