extends CharacterBody2D

@export var speed = 100.0
@export var color = "black"
var last_direction = "down"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func update_animation(state) -> void:
	animated_sprite_2d.play(state + "_" + color + "_" + last_direction)
