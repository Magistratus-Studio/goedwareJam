extends State

@export var Duration: float = 10.0

func enter() -> void:
	cicleTimer.wait_time = Duration
	cicleTimer.timeout.connect(_on_timeout)
	cicleTimer.start()
	print("Ficou de dia")

func _on_timeout() -> void:
	transitioned.emit(self, "Night")

func exit() -> void:
	cicleTimer.stop()
	cicleTimer.timeout.disconnect(_on_timeout)
	print("Acabando o dia")
