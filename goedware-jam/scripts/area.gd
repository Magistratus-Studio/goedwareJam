class_name Area 
extends Node2D

const ENEMY_SCENE: PackedScene = preload("res://objects/enemy/enemy.tscn")

@export var isRiskArea: bool = false

@export_category("Configurações de Spawn do Inimigo")
## Distância horizontal mínima (em pixels) longe do Player
@export var min_spawn_distance: float = 200.0
## Margem das bordas laterais (worldBorders)
@export var border_margin: float = 48.0

var active_enemy: Node2D = null

func _enter_tree() -> void:
	if PlayerController.player:
		PlayerController.setParent(self)

func _ready() -> void:
	var limits: Vector2 = getLimits()
	AreaLimitController.changeMapLimits(limits)
	TimeController.inRiskArea = isRiskArea
	
	var worldBorders: Array[StaticBody2D] = []
	for child in get_children():
		if child is StaticBody2D:
			worldBorders.append(child)
	
	if worldBorders.size() >= 2:
		worldBorders[0].position.x = limits.y
		worldBorders[1].position.x = limits.x
	
	if not TimeController.periodChanged.is_connected(_on_period_changed):
		TimeController.periodChanged.connect(_on_period_changed)
	
	await AreaLimitController.areaLoaded
	_update_enemy_presence()

func _exit_tree() -> void:
	if TimeController.periodChanged.is_connected(_on_period_changed):
		TimeController.periodChanged.disconnect(_on_period_changed)

func _on_period_changed(_new_period: TimeController.Period) -> void:
	_update_enemy_presence()

func _update_enemy_presence() -> void:
	if isRiskArea and TimeController.isNight():
		if not is_instance_valid(active_enemy):
			_spawn_enemy_far_from_player()
	else:
		if is_instance_valid(active_enemy):
			active_enemy.queue_free()
			active_enemy = null

func _spawn_enemy_far_from_player() -> void:
	if ENEMY_SCENE == null or not is_instance_valid(PlayerController.player):
		return
	
	active_enemy = ENEMY_SCENE.instantiate()
	add_child(active_enemy)
	active_enemy.global_position = _get_random_spawn_position()

func _get_random_spawn_position() -> Vector2:
	var player_pos: Vector2 = PlayerController.player.global_position
	var limits: Vector2 = getLimits()
	
	var min_x: float = minf(limits.x, limits.y) + border_margin
	var max_x: float = maxf(limits.x, limits.y) - border_margin
	
	# Calcula os trechos horizontais válidos à esquerda e à direita do Player
	var left_max: float = player_pos.x - min_spawn_distance
	var right_min: float = player_pos.x + min_spawn_distance
	
	var valid_ranges: Array[Vector2] = []
	if left_max > min_x:
		valid_ranges.append(Vector2(min_x, left_max))
	if right_min < max_x:
		valid_ranges.append(Vector2(right_min, max_x))
	
	var spawn_x: float
	if not valid_ranges.is_empty():
		var chosen_range: Vector2 = valid_ranges.pick_random()
		spawn_x = randf_range(chosen_range.x, chosen_range.y)
	else:
		# Fallback caso o mapa seja estreito: nasce na extremidade mais distante do Player
		spawn_x = min_x if absf(player_pos.x - min_x) > absf(max_x - player_pos.x) else max_x
	
	# Mantém exatamente o mesmo Y do Player
	return Vector2(spawn_x, player_pos.y)

func getLimits() -> Vector2:
	var limits: Vector2 = Vector2.ZERO
	limits = get_meta("limits", Vector2(0, 640))
	return limits
