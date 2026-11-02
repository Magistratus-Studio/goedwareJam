extends Node

enum Period { DAY, NIGHT }

signal periodChanged(new_period: Period)

var currentPeriod: Period = Period.DAY
var isTransitioning: bool = false

var inRiskArea: bool = false
var canChangeToDay: bool = true
var maxNightCooldown: float = 60.0
var remainingNightCooldown: float = 0.0

func canChangePeriod() -> bool:
	if currentPeriod == Period.NIGHT:
		return canChangeToDay
	return true

func togglePeriod() -> void:
	if isTransitioning or not canChangePeriod():
		return
	isTransitioning = true
	
	get_tree().paused = true
	await SceneTransition.fadeOut()
	
	currentPeriod = Period.NIGHT if currentPeriod == Period.DAY else Period.DAY
	periodChanged.emit(currentPeriod)
	await get_tree().process_frame
	
	await SceneTransition.fadeIn()
	
	get_tree().paused = false
	isTransitioning = false

func isNight() -> bool:
	return currentPeriod == Period.NIGHT
