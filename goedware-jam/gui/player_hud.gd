extends CanvasLayer

@onready var interact_label: Label = $Control/InteractLabel
@onready var cooldown_bar: ProgressBar = $Control/CooldownBar
@onready var cooldown_label: Label = $Control/CooldownBar/CooldownLabel

@export var head_offset_y: float = -40.0
@export var screen_margin: float = 8.0

func _ready() -> void:
	hide()
	hidePrompt()
	AreaLimitController.areaLoadStarted.connect(hidePrompt)

func _process(_delta: float) -> void:
	_updateCooldownUI()
	
	if not interact_label.visible:
		return
	
	if not is_instance_valid(PlayerController.player) or not PlayerController.player.is_inside_tree():
		hidePrompt()
		return
	
	_updateLabelPosition()

func _updateCooldownUI() -> void:
	if TimeController.isNight() and TimeController.remainingNightCooldown > 0.0:
		cooldown_bar.visible = true
		cooldown_bar.max_value = TimeController.maxNightCooldown
		cooldown_bar.value = TimeController.remainingNightCooldown
		
		if cooldown_label:
			cooldown_label.text = str(ceili(TimeController.remainingNightCooldown)) + "s"
		
		if TimeController.inRiskArea:
			cooldown_bar.modulate = Color(1.0, 1.0, 1.0, 1.0) # Cor normal
		else:
			cooldown_bar.modulate = Color(1.0, 1.0, 1.0, 0.4) # Translúcida para indicar pausa
			if cooldown_label:
				cooldown_label.text = "Pausado"
		
	else:
		cooldown_bar.visible = false

func showPrompt(text: String) -> void:
	interact_label.text = text
	interact_label.reset_size()
	interact_label.visible = true
	_updateLabelPosition()

func hidePrompt() -> void:
	if interact_label:
		interact_label.visible = false

func _updateLabelPosition() -> void:
	var playerScreenPos: Vector2 = PlayerController.player.get_global_transform_with_canvas().origin
	
	var labelSize: Vector2 = interact_label.get_minimum_size()
	var viewportSize: Vector2 = get_viewport().get_visible_rect().size
	
	var targetPos := Vector2(
		playerScreenPos.x - (labelSize.x * 0.5),
		playerScreenPos.y + head_offset_y
	)
	
	var minPos := Vector2(screen_margin, screen_margin)
	var maxPos := (viewportSize - labelSize - Vector2(screen_margin, screen_margin)).max(minPos)
	
	interact_label.global_position = targetPos.clamp(minPos, maxPos)
