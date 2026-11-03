class_name State
extends Node

signal transitioned(state: State, newStateName: String)

func _ready() -> void:
	pass

func enter() -> void:
	pass

func process_state(_delta: float) -> void:
	pass

func physics_process_state(_delta: float) -> void:
	pass

func exit() -> void:
	pass
