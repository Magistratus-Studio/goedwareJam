extends CanvasLayer

signal shown
signal hidden

@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

@export var item_label: Label
@export var description_label: Label


var isPaused: bool = false

func _ready() -> void:
	hidePauseMenu()
	if not save_button.pressed.is_connected(_onSavePressed):
		save_button.pressed.connect(_onSavePressed)
	if not load_button.pressed.is_connected(_onLoadPressed):
		load_button.pressed.connect(_onLoadPressed)
	if not menu_button.pressed.is_connected(_onMenuPressed):
		menu_button.pressed.connect(_onMenuPressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().current_scene.name != "MainScene":
			return
		
		get_viewport().set_input_as_handled()
		if not isPaused:
			showPauseMenu()
		else:
			hidePauseMenu()

func showPauseMenu() -> void:
	get_tree().paused = true
	show()
	isPaused = true
	shown.emit()
	#save_button.grab_focus()

func hidePauseMenu() -> void:
	get_tree().paused = false
	hide()
	isPaused = false
	hidden.emit()

func _onSavePressed() -> void:
	if not isPaused: return
	SaveController.saveGame()
	#mostrar aviso falando que salvou

func _onLoadPressed() -> void:
	if not isPaused: return
	if SaveController.loadGameData():
		SaveController.applySaveData()
		hidePauseMenu() # IMPORTANTE: Tira a pausa do jogo para a transição funcionar
		# Aqui pode mostrar um aviso de sucesso
	else:
		print("Nenhum ficheiro de gravação encontrado.")

func _onMenuPressed() -> void:
	if not isPaused: return
	SaveController.saveGame()
	hidePauseMenu()
	get_tree().change_scene_to_file("res://cenas/menuInicial.tscn")

func updateItemDescription(newText: String) -> void:
	description_label.text = newText

func updateItem(newText: String) -> void:
	item_label.text = newText
