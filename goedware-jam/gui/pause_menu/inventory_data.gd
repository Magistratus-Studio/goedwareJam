class_name InventoryData
extends Resource

@export var slots: Array[SlotData]

func addItem(item: ItemData) -> bool:
	for s in slots:
		if s and s.itemData == item:
			s.acquired = true
			return true
	print("CHEIO")
	return false
