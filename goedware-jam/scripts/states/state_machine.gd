extends Node

@export var initialState: State

var currentState: State
var states: Dictionary = {}

func _ready() -> void:
	for state: State in get_children():
		states[state.name.to_lower()] = state
		state.transitioned.connect(_on_state_transition)
	
	if initialState:
		currentState = initialState
		currentState.enter()

func _process(delta: float) -> void:
	if currentState:
		currentState.process_state(delta)

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.physics_process_state(delta)

func _on_state_transition(state: State, newStateName: String) -> void:
	if state != currentState: 
		return
	
	var newState: State = states.get(newStateName.to_lower())
	if !newState: 
		return
	
	if currentState:
		currentState.exit()
	
	newState.enter()
	currentState = newState
