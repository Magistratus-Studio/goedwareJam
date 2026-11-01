class_name PLayerCamera 
extends Camera2D

func _ready() -> void:
	AreaLimitController.mapLimitChanged.connect(updateLimits)
	#updateLimits(AreaLimitController.curretMapLimits)

func updateLimits(limits: Vector2) -> void:
	limit_left = int(limits.x)
	limit_right = int(limits.y)
