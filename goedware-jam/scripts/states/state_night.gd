class_name StateNight
extends State

@export var cooldown_duration: float = 60.0
var remaining_cooldown: float = 0.0

func enter() -> void:
	TimeController.maxNightCooldown = cooldown_duration
	if not SaveController.is_restoring_save:
		remaining_cooldown = cooldown_duration
		TimeController.remainingNightCooldown = remaining_cooldown
	else:
		remaining_cooldown = TimeController.remainingNightCooldown
	TimeController.canChangeToDay = false
	
	if not TimeController.periodChanged.is_connected(_onPeriodChanged):
		TimeController.periodChanged.connect(_onPeriodChanged)
		print("Ficou de noite")

func process_state(delta: float) -> void:
	if remaining_cooldown > 0.0 and TimeController.inRiskArea:
		remaining_cooldown = max(0.0, remaining_cooldown - delta)
		TimeController.remainingNightCooldown = remaining_cooldown
		
		if remaining_cooldown <= 0.0:
			TimeController.canChangeToDay = true

func exit() -> void:
	if TimeController.periodChanged.is_connected(_onPeriodChanged):
		TimeController.periodChanged.disconnect(_onPeriodChanged)
		print("Acabando a noite")

func _onPeriodChanged(new_period: TimeController.Period) -> void:
	if new_period == TimeController.Period.DAY:
		transitioned.emit(self, "Day")
