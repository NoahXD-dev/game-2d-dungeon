extends CharacterBody2D

@export var speed = 100.0

@export_category("Combat")
@export var max_health: float = 150.0
@export var knockback_friction: float = 800.0
@export var hit_damage: float = 10.0

@export_category("Animation")
@export var color = "black"
@export var last_direction = "down"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hit_collision_shape_2d: CollisionShape2D = $PlayerHitComponent/CollisionShape2D
@onready var hurt_collision_shape_2d: CollisionShape2D = $PlayerHurtComponent/CollisionShape2D

var current_health: float
var knockback_velocity: Vector2 = Vector2.ZERO
signal damaged_player
signal death_player

func _ready() -> void:
	current_health = max_health

func update_animation(state) -> void:
	animated_sprite_2d.play(state + "_" + color + "_" + last_direction)

func _on_player_hurt_component_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var damage_received = body.hit_damage
		take_damage(damage_received, body.global_position)

func take_damage(amount: float, attacker_position: Vector2) -> void:
	if current_health <= 0: return # Ya está muerto, no hacer nada
	
	current_health -= amount
	print("vida restante: ",current_health)
	
	# Calculamos la dirección opuesta al jugador
	var knockback_direction = (global_position - attacker_position).normalized()
	# Le aplicamos una fuerza inicial (ej. 250 píxeles por segundo)
	knockback_velocity = knockback_direction * 350.0
	
	if current_health <= 0:
		death_player.emit()
	else:
		damaged_player.emit() # Avisamos que fuimos heridos
