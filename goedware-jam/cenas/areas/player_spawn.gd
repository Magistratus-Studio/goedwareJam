extends Node2D

func _ready() -> void:
	hide()
	if PlayerController.playerSpawned == false:
		PlayerController.setPlayerPos(global_position)
		PlayerController.playerSpawned = true
