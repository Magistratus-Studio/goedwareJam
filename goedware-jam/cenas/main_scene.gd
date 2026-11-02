extends Node

func _enter_tree() -> void:
	# Garante que a instância do Player exista antes do _ready() da Area filha e do playerSpawn
	PlayerController.addPlayerInstance()

func _ready() -> void:
	# Aguarda um frame para todas as AreaTransition filhas entrarem no await e libera o monitoramento
	await get_tree().process_frame
	AreaLimitController.areaLoaded.emit()

func _exit_tree() -> void:
	# Opcional: limpa o player caso você volte da mainScene para o menuInicial
	PlayerController.removePlayerInstance()
