class_name StateDay
extends State

func enter() -> void:
	if not TimeController.periodChanged.is_connected(_onPeriodChanged):
		TimeController.periodChanged.connect(_onPeriodChanged)
		print("Ficou de dia")

func exit() -> void:
	if TimeController.periodChanged.is_connected(_onPeriodChanged):
		TimeController.periodChanged.disconnect(_onPeriodChanged)
		print("Acabando o dia")

func _onPeriodChanged(new_period: TimeController.Period) -> void:
	if new_period == TimeController.Period.NIGHT:
		transitioned.emit(self, "Night")
