class_name PersistentDataHandler
extends Node

signal dataLoaded
var value: bool = false

func _ready() -> void:
	getValue()

func setValue() -> void:
	SaveController.addPersistetVelue(_getName())

func getValue() -> void:
	value = SaveController.checkPersistetVelue(_getName())
	dataLoaded.emit()

func _getName() -> String:
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
