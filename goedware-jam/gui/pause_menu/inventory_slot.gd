class_name InventorySlotUI
extends PanelContainer

var slotData: SlotData : set = setSlotData

@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	texture_rect.texture = null
	mouse_entered.connect(itemFocused)
	mouse_exited.connect(itemUnfocused)

func setSlotData(value: SlotData) -> void:
	slotData = value
	if slotData == null: return
	if slotData.acquired:
		modulate = Color(1.0,1.0,1.0,1.0)
	texture_rect.texture = slotData.itemData.texture

func itemFocused() -> void:
	if slotData:
		if slotData.itemData:
			PauseMenu.updateItem(slotData.itemData.name)
			PauseMenu.updateItemDescription(slotData.itemData.description)

func itemUnfocused() -> void:
	PauseMenu.updateItem("")
	PauseMenu.updateItemDescription("")
