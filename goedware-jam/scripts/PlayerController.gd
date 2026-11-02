extends Node

const PLAYER = preload("uid://bfs1aybaravrw")
const PLAYER_INVENTORY: InventoryData = preload("uid://cccle2j744hoh")


var player: Player = null
var playerSpawned: bool = false

func addPlayerInstance() -> void:
	if is_instance_valid(player):
		return
	player = PLAYER.instantiate()

func removePlayerInstance() -> void:
	if is_instance_valid(player):
		player.queue_free()
		player = null
	playerSpawned = false

func setPlayerPos(newPos: Vector2) -> void:
	if not is_instance_valid(player):
		addPlayerInstance()
	player.global_position = newPos

func setParent(parent: Node2D) -> void:
	if not is_instance_valid(player):
		addPlayerInstance()
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)
