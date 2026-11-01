extends Node

signal mapLimitChanged(currentMapLimits)
signal areaLoadStarted
signal areaLoaded

var curretMapLimits: Vector2
var targetTransition: String
var positionOffset: Vector2
var isTransitioning: bool = false

func _ready() -> void:
	await get_tree().process_frame
	areaLoaded.emit()

func changeMapLimits(limits: Vector2) -> void:
	curretMapLimits = limits
	mapLimitChanged.emit(limits)

func loadNewArea(areaPath: String, _targetTransition: String, _positionOffset: Vector2) -> void:
	if isTransitioning:
		return
	isTransitioning = true
	
	get_tree().paused = true
	targetTransition = _targetTransition
	positionOffset = _positionOffset
	
	await SceneTransition.fadeOut()
	
	areaLoadStarted.emit()
	await get_tree().process_frame
	
	var currentArea = get_tree().get_first_node_in_group("areas")
	var parent = currentArea.get_parent()
	
	if PlayerController.player and PlayerController.player.get_parent() == currentArea:
		currentArea.remove_child(PlayerController.player)
	
	currentArea.queue_free()
	await get_tree().process_frame
	
	var newArea = load(areaPath).instantiate()
	parent.add_child(newArea)
	
	await SceneTransition.fadeIn()
	
	get_tree().paused = false
	await get_tree().process_frame
	
	isTransitioning = false
	areaLoaded.emit()
