@tool
class_name AreaTransition 
extends Area2D

enum SIDE {LEFT, RIGHT, TOP, BOTTON}
enum ALLOWED_PERIOD {ANY, DAY_ONLY, NIGHT_ONLY}
const PLAYER_INVENTORY = preload("uid://cccle2j744hoh")

@export_file("*.tscn") var level
@export var targetTransitionArea: String = "AreaTransition"
@export var promptText: String = "INTERACT"
@export var offsetAmount: int = 32

@export_category("Access Restrictions")
@export var allowedPeriod: ALLOWED_PERIOD = ALLOWED_PERIOD.ANY
@export var requiredItems: Array[ItemData] = []
@export var lockedPeriodText: String = "LOCKED"
@export var lockedItemsText: String = "MISSING_ITEMS"

@export_category("Collision Area Settings")
@export var side: SIDE = SIDE.LEFT :
	set(value): 
		side = value
		_updateArea()
@export_range(1, 12, 1, "or_greater") var size: int = 2 :
	set(value): 
		size = value
		_updateArea()

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_updateArea()
	if Engine.is_editor_hint():
		set_process_unhandled_input(false)
		return
	
	set_process_unhandled_input(false)
	monitoring = false
	_placePlayer()
	
	await AreaLimitController.areaLoaded
	
	monitoring = true
	await get_tree().physics_frame
	if not body_entered.is_connected(_playerEntered):
		body_entered.connect(_playerEntered)
	if not body_exited.is_connected(_playerExited):
		body_exited.connect(_playerExited)

func _playerEntered(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	PlayerHud.showPrompt(promptText)
	set_process_unhandled_input(true)

func _playerExited(body: Node2D) -> void:
	if body != PlayerController.player:
		return
	PlayerHud.hidePrompt()
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		
		if not canEnter():
			PlayerHud.showPrompt(_getCurrentPrompt())
			return
		
		set_process_unhandled_input(false)
		PlayerHud.hidePrompt()
		AreaLimitController.loadNewArea(level, targetTransitionArea, getOffset())

func _isPeriodAllowed() -> bool:
	match allowedPeriod:
		ALLOWED_PERIOD.DAY_ONLY:
			return not TimeController.isNight()
		ALLOWED_PERIOD.NIGHT_ONLY:
			return TimeController.isNight()
		_:
			return true

func _hasRequiredItems() -> bool:
	if requiredItems.is_empty():
		return true
	return PLAYER_INVENTORY.hasAllItems(requiredItems)

func canEnter() -> bool:
	return _isPeriodAllowed() and _hasRequiredItems()

func _getCurrentPrompt() -> String:
	if not _isPeriodAllowed():
		return lockedPeriodText
	if not _hasRequiredItems():
		return lockedItemsText
	return promptText

func _placePlayer() -> void:
	if name != AreaLimitController.targetTransition:
		return
	PlayerController.setPlayerPos(global_position + AreaLimitController.positionOffset)

func getOffset() -> Vector2:
	var offset = Vector2.ZERO
	var playerPos = PlayerController.player.global_position
	
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		offset.y = playerPos.y - global_position.y
		offset.x = offsetAmount # Maior que 32px para não sobrepor a CollisionShape2D na entrada
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		offset.x = playerPos.x - global_position.x
		offset.y = offsetAmount
		if side == SIDE.TOP:
			offset.y *= -1
	
	return offset

func _updateArea() -> void:
	var newRect: Vector2 = Vector2(32,32)
	var newPos: Vector2 = Vector2.ZERO
	
	match side:
		SIDE.TOP:
			newRect.x *= size
			newPos.y -= 16
		SIDE.BOTTON:
			newRect.x *= size
			newPos.y += 16
		SIDE.LEFT:
			newRect.y *= size
			newPos.x -= 16
		SIDE.RIGHT:
			newRect.y *= size
			newPos.x += 16
	
	if collision_shape_2d == null:
		collision_shape_2d = get_node("CollisionShape2D")
	
	collision_shape_2d.shape.size = newRect
	collision_shape_2d.position = newPos
