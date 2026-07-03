extends CharacterBody2D

@export var speed = 100.0
@export var color = "black"
var last_direction = "down"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
