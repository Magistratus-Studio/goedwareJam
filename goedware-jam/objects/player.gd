class_name Player 
extends CharacterBody2D


const SPEED = 300.0

var cardinalDirection: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var state: String = "idle"

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	direction.x = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if setState() == true || setDirection() == true:
		updateAnimation()
	
	move_and_slide()
	clamp(position.x, AreaLimitController.curretMapLimits.y, AreaLimitController.curretMapLimits.y)

func setDirection() -> bool:
	var newDir: Vector2 = cardinalDirection
	if direction == Vector2.ZERO:
		return false
	
	newDir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	if newDir == cardinalDirection:
		return false
	
	cardinalDirection = newDir
	sprite.scale.x = -1 if cardinalDirection == Vector2.LEFT else 1
	return true

func setState() -> bool:
	var newState: String = "idle" if direction == Vector2.ZERO else "walk"
	
	if newState == state: 
		return false
	
	state = newState
	return true

func updateAnimation() -> void:
	animationPlayer.play(state)

func spriteDirection() -> void:
	pass
