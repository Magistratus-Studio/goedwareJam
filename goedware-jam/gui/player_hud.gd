extends CanvasLayer

@onready var interact_label: Label = $Control/InteractLabel

# Distância acima do ponto de origem do Player
@export var head_offset_y: float = -40.0

# Margem mínima (em pixels) entre o texto e as bordas da câmera/tela
@export var screen_margin: float = 8.0

func _ready() -> void:
	hidePrompt()
	# Garante que o texto suma automaticamente ao iniciar o carregamento de uma nova área
	AreaLimitController.areaLoadStarted.connect(hidePrompt)

func _process(_delta: float) -> void:
	if not interact_label.visible:
		return
	
	if not is_instance_valid(PlayerController.player) or not PlayerController.player.is_inside_tree():
		hidePrompt()
		return
	
	_updateLabelPosition()

func showPrompt(text: String) -> void:
	interact_label.text = text
	interact_label.reset_size()
	interact_label.visible = true
	_updateLabelPosition()

func hidePrompt() -> void:
	if interact_label:
		interact_label.visible = false

func _updateLabelPosition() -> void:
	# Posição do Player convertida para as coordenadas da tela (Canvas)
	var playerScreenPos: Vector2 = PlayerController.player.get_global_transform_with_canvas().origin
	
	# Usa get_minimum_size() para garantir a largura/altura exata mesmo no 1º frame após trocar o texto
	var labelSize: Vector2 = interact_label.get_minimum_size()
	var viewportSize: Vector2 = get_viewport().get_visible_rect().size
	
	# Posição ideal centralizada acima da cabeça do Player
	var targetPos := Vector2(
		playerScreenPos.x - (labelSize.x * 0.5),
		playerScreenPos.y + head_offset_y
	)
	
	# Define os limites mínimos (canto superior esquerdo) e máximos (canto inferior direito)
	var minPos := Vector2(screen_margin, screen_margin)
	var maxPos := (viewportSize - labelSize - Vector2(screen_margin, screen_margin)).max(minPos)
	
	# Trava a posição final dentro da área visível da câmera
	interact_label.global_position = targetPos.clamp(minPos, maxPos)
