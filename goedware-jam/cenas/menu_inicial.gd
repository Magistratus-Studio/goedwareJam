extends Control

@export_category("Cenas")
@export var mainScene: PackedScene

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)


func _on_continue_button_pressed() -> void:
	if SaveController.loadGameData():
		SaveController.is_loading_from_menu = true
		get_tree().change_scene_to_packed(mainScene)
	else:
		print("Nenhum jogo guardado para carregar.")


func _on_config_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
