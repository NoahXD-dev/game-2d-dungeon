extends CharacterBody2D

@export var speed = 50.0

@export_category("Waypoins")
@export var waypoints: Array[Marker2D]

@export_category("Vision")
@export var angle_vision: float = 60.0
@export var lenght_cone_vision: float = 50.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var last_direction: String = "down"
var last_direction_vision: Vector2 = Vector2.DOWN
var half_angle_rads

var current_index: int = 0
var is_waiting: bool = false
var stop_distance: float = 10.0

enum State { IDLE_PATROL, CHASING, INVESTIGATING }
var current_state: State = State.IDLE_PATROL
var last_known_position: Vector2 = Vector2.ZERO

var player: CharacterBody2D

func  _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	half_angle_rads = deg_to_rad(angle_vision / 2)

func _draw() -> void:
	var left_dir = last_direction_vision.rotated(-half_angle_rads) * lenght_cone_vision
	var right_dir = last_direction_vision.rotated(half_angle_rads) * lenght_cone_vision
	
	draw_line(Vector2.ZERO, left_dir, Color.RED, 2.0, )
	draw_line(Vector2.ZERO, right_dir, Color.RED, 2.0, )

func _physics_process(_delta: float) -> void:
	queue_redraw()
	
	if player != null and is_in_cone() and has_line_of_sight():
		# Ve al jugador activamente: actualiza la última posición conocida
		current_state = State.CHASING
		last_known_position = player.global_position
		chase_player()
		return
	
	match current_state:
		State.CHASING:
			# Acaba de perder de vista al jugador: cambia a investigar
			current_state = State.INVESTIGATING
			investigate_last_position()
		State.INVESTIGATING:
			investigate_last_position()
		State.IDLE_PATROL:
			if waypoints.size() > 0:
				chase_waypoints()
			else:
				set_state(Vector2.ZERO)

func is_in_cone() -> bool:
	var player_local = to_local(player.position)
	var angle_to_player = last_direction_vision.angle_to(player_local)
	var distance = player_local.length()
	
	if distance > lenght_cone_vision:
		return false
	
	return abs(angle_to_player) <= half_angle_rads

func has_line_of_sight() -> bool:
	ray_cast_2d.target_position = ray_cast_2d.to_local(player.position)
	
	if not ray_cast_2d.is_colliding():
		return false
	
	var collider = ray_cast_2d.get_collider()
	return collider.is_in_group("player")

func chase_player() -> void:
	navigation_agent_2d.target_position = player.global_position
	
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		set_state(Vector2.ZERO)
		move_and_slide()
		return
	
	var next_pos = navigation_agent_2d.get_next_path_position()
	var delta_pos = next_pos - global_position
	var distance = delta_pos.length()
	
	if distance <= stop_distance:
		velocity = Vector2.ZERO
		set_state(Vector2.ZERO)
		move_and_slide()
		return
	
	_update_vision_direction(delta_pos.normalized())
	set_state(delta_pos.normalized())
	velocity = delta_pos.normalized() * speed
	move_and_slide()

func investigate_last_position() -> void:
	navigation_agent_2d.target_position = last_known_position
	
	if navigation_agent_2d.is_navigation_finished():
		# Llegó al último lugar conocido y no encontró al jugador: vuelve a patrullar
		current_state = State.IDLE_PATROL
		velocity = Vector2.ZERO
		set_state(Vector2.ZERO)
		move_and_slide()
		return
	
	var next_pos = navigation_agent_2d.get_next_path_position()
	var delta_pos = next_pos - global_position
	var distance = delta_pos.length()
	
	if distance <= stop_distance:
		velocity = Vector2.ZERO
		set_state(Vector2.ZERO)
		move_and_slide()
		return
	
	_update_vision_direction(delta_pos.normalized())
	set_state(delta_pos.normalized())
	velocity = delta_pos.normalized() * speed
	move_and_slide()

func chase_waypoints() -> void:
	if is_waiting:
		set_state(Vector2.ZERO)
		return
	
	navigation_agent_2d.target_position = waypoints[current_index].global_position
	
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		is_waiting = true
		timer.start()
		move_and_slide()
		return
	
	var next_pos = navigation_agent_2d.get_next_path_position()
	var delta_pos = next_pos - global_position
	
	set_state(delta_pos.normalized())
	velocity = delta_pos.normalized() * speed
	move_and_slide()

func set_state(direction: Vector2) -> void:
	if(direction == Vector2.ZERO):
		velocity = Vector2.ZERO
		play_animation("idle")
		return
	
	if abs(direction.x) > abs(direction.y):
		#Movimiento Horizontal
		last_direction = "right" if direction.x > 0 else "left"
	else:
		#Movimiento Vertical
		last_direction = "down" if direction.y > 0 else "up"
	
	_update_vision_direction(direction)
	play_animation("run")

func _update_vision_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		last_direction_vision = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	else:
		last_direction_vision = Vector2.DOWN if direction.y > 0 else Vector2.UP

func play_animation(state: String) -> void:
	animated_sprite_2d.play(state + "_" + last_direction)

func _on_timer_timeout() -> void:
	if waypoints.size() > 0:
		is_waiting = false
		current_index = (current_index + 1) % waypoints.size()
