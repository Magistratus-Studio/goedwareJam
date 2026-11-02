@tool
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var itemData: ItemData : set = _setItemData

func _ready() -> void:
	_updateTexture()
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect(_onBodyEnter)

func _onBodyEnter(b) -> void:
	if b is Player:
		if PlayerController.PLAYER_INVENTORY.addItem(itemData):
			itemPickUp()

func itemPickUp() -> void:
	area_2d.body_entered.disconnect(_onBodyEnter)
	#tocar audio possivelmente
	hide()
	#await audio_stream_player_2d.finished
	queue_free()

func _setItemData(value: ItemData) -> void:
	itemData = value
	_updateTexture()

func _updateTexture() -> void:
	if itemData and sprite_2d:
		sprite_2d.texture = itemData.texture
