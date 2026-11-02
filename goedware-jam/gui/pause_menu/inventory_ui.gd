class_name InventoryUI
extends Control

const INVENTORY_SLOT = preload("uid://300l55ae8enh")

@export var data: InventoryData

func _ready() -> void:
	PauseMenu.shown.connect(updateInventory)
	PauseMenu.hidden.connect(clearInventory)
	clearInventory()

func clearInventory() -> void:
	for c in get_children():
		c.queue_free()

func updateInventory() -> void:
	for s in data.slots:
		var newSlot = INVENTORY_SLOT.instantiate()
		add_child(newSlot)
		newSlot.slotData = s
