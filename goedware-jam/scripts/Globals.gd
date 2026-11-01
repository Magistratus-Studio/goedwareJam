extends Node

var curretMapLimits: Vector2
signal mapLimitChanged(currentMapLimits)

func changeMapLimits(limits: Vector2) -> void:
	curretMapLimits = limits
	mapLimitChanged.emit(limits)
