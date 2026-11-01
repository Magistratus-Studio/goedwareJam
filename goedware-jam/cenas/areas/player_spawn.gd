extends Node2D

func _ready() -> void:
	hide()
	if not PlayerController.playerSpawned:
		PlayerController.setPlayerPos(global_position)
		PlayerController.playerSpawned = true
