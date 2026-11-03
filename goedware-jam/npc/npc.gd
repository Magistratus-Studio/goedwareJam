@tool
class_name NPC
extends Area2D

const PLAYER_INVENTORY: InventoryData = preload("res://gui/pause_menu/playerInventory.tres")

@export_category("Visual e Identidade")
@export var npc_name: String = "Aldeão"
@export var npc_texture: Texture2D :
	set(value):
		npc_texture = value
		_update_sprite()

@export var h_frames: int = 1 :
	set(value):
		h_frames = max(1, value)
		_update_sprite()
@export var v_frames: int = 1 :
	set(value):
		v_frames = max(1, value)
		_update_sprite()
@export var sprite_frame: int = 0 :
	set(value):
		sprite_frame = max(0, value)
		_update_sprite()

@export var prompt_text: String = "HUD_TALK"
@export var face_player_on_talk: bool = true
@export var npc_csv_id: String = ""

@export_category("Sequências de Diálogo")
@export_multiline var day_dialog: Array[String] = [
	"Olá, viajante.",
	"Cuidado ao andar por aí depois que escurecer."
]

@export_multiline var night_dialog: Array[String] = [
	"O que fazes fora de casa a esta hora?!",
	"A floresta fica perigosa durante a noite."
]

@export_category("Diálogo Condicional por Itens")
@export var required_items: Array[ItemData] = []
@export_multiline var item_dialog: Array[String] = []
@export var item_dialog_only_at_night: bool = false

@export_category("Regras de Aparecimento Noturno")
@export var disappear_at_night: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_update_sprite()
	if Engine.is_editor_hint():
		set_process_unhandled_input(false)
		return
	
	if not npc_csv_id.is_empty():
		npc_name = "NPC_%s_NAME" % npc_csv_id.to_upper()
		if day_dialog.is_empty():
			day_dialog = _get_csv_sequence("DAY")
		if night_dialog.is_empty():
			night_dialog = _get_csv_sequence("NIGHT")
		if item_dialog.is_empty():
			item_dialog = _get_csv_sequence("ITEM")
	
	set_process_unhandled_input(false)
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	_check_night_presence()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Checagem contínua simples e segura para garantir que o NPC suma assim que virar noite
	_check_night_presence()

func _check_night_presence() -> void:
	# Se a flag estiver desativada, o NPC nunca some à noite
	if not disappear_at_night:
		_set_npc_visible(true)
		return
	
	# Se a flag estiver ativada, esconde o NPC e bloqueia a interação durante a noite
	if TimeController.isNight():
		_set_npc_visible(false)
	else:
		_set_npc_visible(true)

func _set_npc_visible(is_vis: bool) -> void:
	visible = is_vis
	# Desliga o monitoramento da Area2D para impedir que o player interaja ou ative o prompt na HUD
	set_deferred("monitoring", is_vis)

func _get_csv_sequence(dialog_type: String) -> Array[String]:
	var result: Array[String] = []
	if npc_csv_id.is_empty():
		return result
	
	var index: int = 1
	while true:
		var key: String = "NPC_%s_%s_%d" % [npc_csv_id.to_upper(), dialog_type.to_upper(), index]
		# Na Godot, quando tr(key) é igual à própria key, significa que a chave não existe no CSV
		if tr(key) == key:
			break
		result.append(key)
		index += 1
	
	return result

func _update_sprite() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		return
	
	sprite.texture = npc_texture
	sprite.hframes = h_frames
	sprite.vframes = v_frames
	sprite.frame = clampi(sprite_frame, 0, (h_frames * v_frames) - 1)

func _on_player_entered(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	PlayerHud.showPrompt(prompt_text)
	set_process_unhandled_input(true)

func _on_player_exited(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	PlayerHud.hidePrompt()
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not DialogSystem.is_active:
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		PlayerHud.hidePrompt()
		
		if face_player_on_talk and sprite and is_instance_valid(PlayerController.player):
			var dir_x: float = PlayerController.player.global_position.x - global_position.x
			if abs(dir_x) > 4.0:
				sprite.flip_h = (dir_x < 0)
		
		var lines_to_show: Array[String] = _get_active_dialog()
		DialogSystem.show_dialog(lines_to_show, npc_name)
		
		await DialogSystem.finished
		
		if get_overlapping_bodies().has(PlayerController.player):
			PlayerHud.showPrompt(prompt_text)
			set_process_unhandled_input(true)

func _get_active_dialog() -> Array[String]:
	if not required_items.is_empty() and not item_dialog.is_empty():
		var period_ok: bool = (not item_dialog_only_at_night) or TimeController.isNight()
		if period_ok and PLAYER_INVENTORY.hasAllItems(required_items):
			return item_dialog
	
	if TimeController.isNight() and not night_dialog.is_empty():
		return night_dialog
	
	return day_dialog
