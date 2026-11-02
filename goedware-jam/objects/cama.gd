extends Area2D

@export var dayPromptText: String = "INTERECT_CHANGE_TO_NIGHT"
@export var nightPromptText: String = "INTERECT_CHANGE_TO_DAY"
@export var cooldownPromptText: String = "INTERECT_CHANGE_COOLDOWN"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	set_process_unhandled_input(false)
	
	if not body_entered.is_connected(_playerEntered):
		body_entered.connect(_playerEntered)
	if not body_exited.is_connected(_playerExited):
		body_exited.connect(_playerExited)

func _playerEntered(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	
	_updatePrompt()
	set_process_unhandled_input(true)

func _playerExited(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	PlayerHud.hidePrompt()
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		PlayerHud.hidePrompt()
		
		await TimeController.togglePeriod()
		
		# Se o jogador continuar dentro da área após o fadeIn, mostra o novo texto atualizado
		if get_overlapping_bodies().has(PlayerController.player):
			_updatePrompt()
			set_process_unhandled_input(true)

func _updatePrompt() -> void:
	if TimeController.isNight():
		if TimeController.canChangePeriod():
			PlayerHud.showPrompt(nightPromptText)
		else:
			PlayerHud.showPrompt(cooldownPromptText)
	else:
		PlayerHud.showPrompt(dayPromptText)
