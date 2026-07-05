extends CharacterBody2D

@export var speed = 100.0
@export var life: float = 150.0
@export var hit_damage: float = 10.0

@export_category("Animation")
@export var color = "black"
@export var last_direction = "down"

@onready var hit_collision_shape_2d: CollisionShape2D = $PlayerHitComponent/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func update_animation(state) -> void:
	animated_sprite_2d.play(state + "_" + color + "_" + last_direction)
