extends Node

enum Period { DAY, NIGHT }
const HOME_SCENE_PATH: String = "res://cenas/areas/casaJogador.tscn"

signal periodChanged(new_period: Period)

var currentPeriod: Period = Period.DAY
var isTransitioning: bool = false

var inRiskArea: bool = false
var canChangeToDay: bool = true
var maxNightCooldown: float = 60.0
var remainingNightCooldown: float = 0.0

func handlePlayerCaught() -> void:
	if isTransitioning:
		return
	isTransitioning = true
	
	# Permite que o nó playerSpawn da casaJogador reposicione o Player ao carregar a cena
	PlayerController.playerSpawned = false
	
	# Inicia a troca de área com fadeOut / fadeIn pelo AreaLimitController
	AreaLimitController.loadNewArea(HOME_SCENE_PATH, "", Vector2.ZERO)
	
	# Aguarda a tela ficar totalmente preta antes de virar dia
	await AreaLimitController.areaLoadStarted
	
	currentPeriod = Period.DAY
	remainingNightCooldown = 0.0
	canChangeToDay = true
	inRiskArea = false
	periodChanged.emit(currentPeriod)
	
	await AreaLimitController.areaLoaded
	isTransitioning = false

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
