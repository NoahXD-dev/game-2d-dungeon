extends CharacterBody2D

@export var speed = 100.0
var last_direction = "down"

@onready var animated_sprite = $AnimatedSprite

func _physics_process(_delta) -> void:
	get_input()
	move_and_slide()

func  get_input() -> void:
	var input_ditection: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_ditection == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return
	
	if abs(input_ditection.x) > abs(input_ditection.y):
		#Movimiento Horizontal
		if input_ditection.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if input_ditection.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"
	
	update_animation("run")
	velocity = input_ditection * speed

func update_animation(state) -> void:
	animated_sprite.play(state + "_" + last_direction)
