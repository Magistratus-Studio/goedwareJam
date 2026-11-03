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

# Verifica se o jogador possui pelo menos 1 unidade de um item específico
func hasItem(item: ItemData) -> bool:
	for slot: SlotData in slots:
		if slot != null and slot.itemData == item and slot.acquired:
			return true
	return false

# Verifica se o jogador possui TODOS os itens de uma lista
func hasAllItems(required_items: Array[ItemData]) -> bool:
	for item: ItemData in required_items:
		if item != null and not hasItem(item):
			return false
	return true
