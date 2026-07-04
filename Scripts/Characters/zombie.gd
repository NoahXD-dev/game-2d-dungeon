extends CharacterBody2D

@export var speed: float = 50.0

@export_category("Waypoints")
@export var waypoints: Array[Marker2D]

@export_category("Vision")
@export var angle_vision: float = 60.0
@export var lenght_cone_vision: float = 50.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var state_machine: StateMachine = $StateMachine # Ajusta la ruta si es diferente

var last_direction: String = "down"
var last_direction_vision: Vector2 = Vector2.DOWN
var half_angle_rads: float

var current_index: int = 0
var stop_distance: float = 10.0
var last_known_position: Vector2 = Vector2.ZERO
var is_waiting: bool = false
var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	half_angle_rads = deg_to_rad(angle_vision / 2)

func _process(_delta: float) -> void:
	# El dibujo necesita actualizarse constantemente
	queue_redraw()

func _draw() -> void:
	var left_dir = last_direction_vision.rotated(-half_angle_rads) * lenght_cone_vision
	var right_dir = last_direction_vision.rotated(half_angle_rads) * lenght_cone_vision
	
	draw_line(Vector2.ZERO, left_dir, Color.RED, 2.0)
	draw_line(Vector2.ZERO, right_dir, Color.RED, 2.0)

# Métodos de utilidad que los estados usarán:

func check_vision() -> bool:
	if player == null: return false
	return is_in_cone() and has_line_of_sight()

func is_in_cone() -> bool:
	var player_local = to_local(player.global_position)
	var angle_to_player = last_direction_vision.angle_to(player_local)
	var distance = player_local.length()
	
	if distance > lenght_cone_vision:
		return false
	
	return abs(angle_to_player) <= half_angle_rads

func has_line_of_sight() -> bool:
	ray_cast_2d.target_position = ray_cast_2d.to_local(player.global_position)
	ray_cast_2d.force_raycast_update() # Asegura datos limpios antes de leer colisiones
	
	if not ray_cast_2d.is_colliding():
		return false
	
	var collider = ray_cast_2d.get_collider()
	return collider.is_in_group("player")

func set_movement_state(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		play_animation("idle")
		return
	
	if abs(direction.x) > abs(direction.y):
		last_direction = "right" if direction.x > 0 else "left"
	else:
		last_direction = "down" if direction.y > 0 else "up"
	
	_update_vision_direction(direction)
	play_animation("run")

func _update_vision_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		last_direction_vision = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	else:
		last_direction_vision = Vector2.DOWN if direction.y > 0 else Vector2.UP

func play_animation(state_name: String) -> void:
	animated_sprite_2d.play(state_name + "_" + last_direction)
