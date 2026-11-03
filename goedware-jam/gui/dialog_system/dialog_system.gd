extends CanvasLayer

signal finished

@onready var dialog_ui: Control = $DialogUI
@onready var name_label: Label = $DialogUI/PanelContainer/VBoxContainer/NameLabel
@onready var content: RichTextLabel = $DialogUI/PanelContainer/VBoxContainer/Content
@onready var progress_indicator: Label = $DialogUI/ProgressIndicator
@onready var timer: Timer = $Timer

@export var text_speed: float = 0.02

var is_active: bool = false
var text_in_progress: bool = false
var dialog_lines: Array[String] = []
var current_index: int = 0
var text_length: int = 0
var plain_text: String = ""

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	hide_dialog()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		# Se o texto ainda está sendo digitado, revela a frase inteira imediatamente
		if text_in_progress:
			timer.stop()
			content.visible_characters = text_length
			text_in_progress = false
			_update_indicator(true)
			return
		
		# Avança para a próxima fala da sequência ou encerra o diálogo
		current_index += 1
		if current_index < dialog_lines.size():
			_start_line()
		else:
			hide_dialog()

func show_dialog(lines: Array[String], speaker_name: String = "") -> void:
	if lines.is_empty():
		return
	
	dialog_lines = lines
	current_index = 0
	
	name_label.visible = (speaker_name != "")
	# Traduz o nome do NPC caso seja uma chave do CSV (ex: "NPC_VELHO_NAME")
	name_label.text = tr(speaker_name)
	
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	await get_tree().process_frame
	is_active = true
	_start_line()

func hide_dialog() -> void:
	is_active = false
	text_in_progress = false
	timer.stop()
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()

func _start_line() -> void:
	_update_indicator(false)
	# Traduz a chave da fala atual ANTES de contar os caracteres e remover o BBCode
	content.text = tr(dialog_lines[current_index])
	content.visible_characters = 0
	
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	_start_timer()

func _start_timer() -> void:
	timer.wait_time = text_speed
	# Pausa ligeiramente maior em pontuações (técnica do E34)
	if content.visible_characters > 0 and content.visible_characters <= plain_text.length():
		var current_char: String = plain_text[content.visible_characters - 1]
		if ".,!?:;".contains(current_char):
			timer.wait_time = text_speed * 4.0
	timer.start()

func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters < text_length:
		_start_timer()
	else:
		text_in_progress = false
		_update_indicator(true)

func _update_indicator(is_visible: bool) -> void:
	progress_indicator.visible = is_visible
	if current_index + 1 < dialog_lines.size():
		progress_indicator.text = tr("HUD_NEXT")
	else:
		progress_indicator.text = tr("HUD_CLOSE")
