extends Node2D

func _enter_tree() -> void:
	if SaveController.is_loading_from_menu:
		hide()
	PlayerController.addPlayerInstance()
	PlayerHud.show()

func _ready() -> void:
	await get_tree().process_frame
	if SaveController.is_loading_from_menu:
		SaveController.is_loading_from_menu = false
		SaveController.applySaveData()
		await AreaLimitController.areaLoadStarted
		show()
	else:
		AreaLimitController.areaLoaded.emit()

func _exit_tree() -> void:
	PlayerController.removePlayerInstance()
	PlayerHud.hide()
