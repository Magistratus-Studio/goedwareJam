class_name PLayerCamera 
extends Camera2D

func _ready() -> void:
	Globals.mapLimitChanged.connect(updateLimits)
	#updateLimits(Globals.curretMapLimits)

func updateLimits(limits: Vector2) -> void:
	limit_left = int(limits.x)
	limit_right = int(limits.y)
