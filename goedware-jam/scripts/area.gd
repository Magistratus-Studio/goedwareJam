class_name Area 
extends Node2D

func _ready() -> void:
	Globals.changeMapLimits(getLimits())
	
	var worldBorders: Array[StaticBody2D] = []
	for child in get_children():
		if child is StaticBody2D:
			worldBorders.append(child)
	
	worldBorders[0].position.x = getLimits().y
	worldBorders[1].position.x = getLimits().x

func getLimits() -> Vector2:
	var limits: Vector2 = Vector2.ZERO
	
	limits = get_meta("limits", Vector2(0, 640))
	return limits
