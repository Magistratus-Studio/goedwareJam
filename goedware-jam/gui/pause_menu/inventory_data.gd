class_name InventoryData
extends Resource

@export var slots: Array[SlotData]

enum ITEMS {MEL, FUMO, CHAVE, TERCO, JUREMA, DOCUMENTO}

func addItem(item: ItemData) -> bool:
	for s in slots:
		if s and s.itemData == item:
			s.acquired = true
			return true
	print("CHEIO")
	return false

func getSaveData() -> Array:
	var itemSave: Array = []
	for s in slots:
		itemSave.append(s.acquired)
	return itemSave

func loadSaveData(items: Array) -> void:
	for i in slots.size():
		slots[i].acquired = items[i]
