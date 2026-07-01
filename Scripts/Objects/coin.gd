extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

var colores = ["blue", "red", "green", "gold", "silver", "copper"]
@export var color = ""

func _ready() -> void:
	if color.is_empty() or not colores.has(color):
		color = colores[randi() % colores.size()]
	
	update_animation("idle")

func update_animation(state) -> void:
	animated_sprite.play(state+"_"+color)

func _on_body_entered(_body: Node2D) -> void:
	update_animation("pickup")
	await animated_sprite.animation_finished
	queue_free()
