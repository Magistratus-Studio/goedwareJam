class_name NightEnemy
extends CharacterBody2D

enum STATE { ROAM, CHASE }

@export_category("Movimentação")
@export var roam_speed: float = 45.0
@export var chase_speed: float = 85.0

@export_category("Detecção")
@export var detection_radius: float = 140.0
@export var lose_interest_radius: float = 220.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var catch_area: Area2D = $CatchArea

var current_STATE: STATE = STATE.ROAM
var roam_dir_x: float = 0.0
var roam_timer: float = 0.0
var is_catching_player: bool = false

func _ready() -> void:
	_pick_new_roam_direction()
	catch_area.body_entered.connect(_on_catch_area_body_entered)

func _physics_process(delta: float) -> void:
	if is_catching_player or not is_instance_valid(PlayerController.player):
		velocity = Vector2.ZERO
		return
	
	var player_x: float = PlayerController.player.global_position.x
	var distance_x: float = absf(player_x - global_position.x)
	
	# Transição de estados usando apenas a distância horizontal
	if current_STATE == STATE.ROAM and distance_x <= detection_radius:
		current_STATE = STATE.CHASE
	elif current_STATE == STATE.CHASE and distance_x >= lose_interest_radius:
		current_STATE = STATE.ROAM
		_pick_new_roam_direction()
	
	# Movimentação restrita ao eixo X (velocity.y é sempre 0)
	match current_STATE:
		STATE.ROAM:
			roam_timer -= delta
			if roam_timer <= 0.0:
				_pick_new_roam_direction()
			velocity.x = roam_dir_x * roam_speed
		STATE.CHASE:
			var dir_to_player: float = signf(player_x - global_position.x)
			velocity.x = dir_to_player * chase_speed
	
	velocity.y = 0.0
	
	if absf(velocity.x) > 1.0 and sprite:
		sprite.flip_h = (velocity.x < 0.0)
	
	move_and_slide()
	
	# Se encostar no limite lateral do mapa (worldBorders), inverte o lado da patrulha
	if current_STATE == STATE.ROAM and is_on_wall():
		roam_dir_x *= -1.0
		roam_timer = randf_range(1.2, 3.0)

func _pick_new_roam_direction() -> void:
	roam_timer = randf_range(1.2, 3.0)
	# 25% de chance de parar brevemente, 75% de andar para esquerda (-1) ou direita (1)
	if randf() < 0.25:
		roam_dir_x = 0.0
	else:
		roam_dir_x = -1.0 if randf() < 0.5 else 1.0

func _on_catch_area_body_entered(body: Node2D) -> void:
	if is_catching_player or body != PlayerController.player:
		return
	
	is_catching_player = true
	set_physics_process(false)
	catch_area.set_deferred("monitoring", false)
	
	TimeController.handlePlayerCaught()
