extends Node

const PLAYER = preload("uid://bfs1aybaravrw")
var player: Player
var playerSpawned: bool = false

func _ready() -> void:
	addPlayerInstance()
	await get_tree().create_timer(0.5).timeout
	playerSpawned = true

func addPlayerInstance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

func setPlayerPos(newPos: Vector2) -> void:
	player.global_position = newPos

func setParent(parent: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)
