extends State

@export var Duration: float = 10.0

func enter() -> void:
	cicleTimer.wait_time = Duration
	cicleTimer.timeout.connect(_on_timeout)
	cicleTimer.start()
	print("Ficou de noite")

func _on_timeout() -> void:
	transitioned.emit(self, "Day")

func exit() -> void:
	cicleTimer.stop()
	cicleTimer.timeout.disconnect(_on_timeout)
	print("Acabando a noite")
