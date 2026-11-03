extends Node

const SAVE_PATH = "user://"

signal gameLoaded
signal gameSaved

var is_loading_from_menu: bool = false
var is_restoring_save: bool = false

var currentSave: Dictionary = {
	scenePath = "",
	player = {
		items = [],
		posX = 0,
		posY = 0
	},
	period = null,
	cooldown = 0,
	persistence = [],
	quests = []
}

func saveGame() -> void:
	updateSaveData()
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	var SaveJSON = JSON.stringify(currentSave)
	
	file.store_line(SaveJSON)
	gameSaved.emit()
	print("A guardar o jogo...") # Atualizado

func loadGameData() -> bool:
	if not FileAccess.file_exists(SAVE_PATH + "save.sav"):
		return false
		
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)
	var json: JSON = JSON.new()
	json.parse(file.get_line())
	currentSave = json.get_data() as Dictionary
	return true

func applySaveData() -> void:
	is_restoring_save = true
	if currentSave.period != null:
		TimeController.currentPeriod = currentSave.period
		TimeController.remainingNightCooldown = currentSave.cooldown
		TimeController.periodChanged.emit(TimeController.currentPeriod)
	
	AreaLimitController.loadNewArea(currentSave.scenePath, "", Vector2.ZERO)
	await AreaLimitController.areaLoadStarted
	
	var playerPos: Vector2 = Vector2(currentSave.player.posX, currentSave.player.posY)
	PlayerController.setPlayerPos(playerPos)
	var items: Array = currentSave.player.items
	PlayerController.PLAYER_INVENTORY.loadSaveData(items)
	
	await AreaLimitController.areaLoaded
	
	is_restoring_save = false
	gameLoaded.emit()
	print("Jogo carregado!")

func updateSaveData() -> void:
	updatePlayerData()
	updateScenePath()
	updateTimeData()

func updatePlayerData() -> void:
	var p: Player = PlayerController.player
	var items: Array = PlayerController.PLAYER_INVENTORY.getSaveData()
	currentSave.player.posX = p.global_position.x
	currentSave.player.posY = p.global_position.y
	currentSave.player.items = items

func updateScenePath() -> void:
	var path: String = ""
	var current_area = get_tree().get_first_node_in_group("areas")
	if current_area:
		path = current_area.scene_file_path
	currentSave.scenePath = path

func updateTimeData() -> void:
	currentSave.period = TimeController.currentPeriod
	currentSave.cooldown = TimeController.remainingNightCooldown

func addPersistetVelue(value: String) -> void:
	if not checkPersistetVelue(value):
		currentSave.persistence.append(value)

func checkPersistetVelue(value: String) -> bool:
	var p = currentSave.persistence
	return p.has(value)
