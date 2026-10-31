class_name State
extends Node

signal transitioned(state: State, newStateName: String)

@onready var cicleTimer: Timer = get_tree().get_first_node_in_group("CicleTimer")

func _ready() -> void:
	pass

func enter() -> void:
	pass

func process_state(delta: float) -> void:
	pass

func physics_process_state(delta: float) -> void:
	pass

func exit() -> void:
	pass
