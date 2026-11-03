class_name Hideout
extends Area2D

@export var enterPromptText: String = "HUD_ENTER_HIDEOUT"
@export var exitPromptText: String = "HUD_EXIT_HIDEOUT"

var player_is_inside: bool = false
var is_hiding: bool = false

func _ready() -> void:
	set_process_unhandled_input(false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	player_is_inside = true
	_update_prompt()
	set_process_unhandled_input(true)

func _on_body_exited(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	player_is_inside = false
	
	if is_hiding:
		_toggle_hiding(false)
	
	PlayerHud.hidePrompt()
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_is_inside:
		get_viewport().set_input_as_handled()
		_toggle_hiding(not is_hiding)
		_update_prompt()

func _toggle_hiding(hide: bool) -> void:
	is_hiding = hide
	TimeController.is_hidden = hide
	
	if is_hiding:
		# Opcional: esconde o sprite do jogador enquanto ele estiver dentro
		PlayerController.player.visible = false
		# Desliga a colisão do player para o inimigo não conseguir tocá-lo de jeito nenhum
		PlayerController.player.set_collision_layer_value(2, false) # Ajuste o número da layer conforme seu projeto
	else:
		PlayerController.player.visible = true
		PlayerController.player.set_collision_layer_value(2, true)

func _update_prompt() -> void:
	if is_hiding:
		PlayerHud.showPrompt(exitPromptText)
	else:
		PlayerHud.showPrompt(enterPromptText)
