class_name StateMachine extends Node

# Nodo que vamos a controlar
@onready var controlled_node = self.owner

# Estado por defecto
@export var default_state: StateBase

# Estado de ejecucion en cada momento
var current_state: StateBase = null

func _ready() -> void:
	call_deferred("_state_default_start")
	
	if controlled_node.has_signal("damaged_enemy"):
		controlled_node.damaged_enemy.connect(func(): change_to("EnemyStateHurt"))
	
	if controlled_node.has_signal("death_enemy"):
		controlled_node.death_enemy.connect(func(): change_to("EnemyStateDeath"))

func _state_default_start() -> void:
	current_state = default_state
	_state_start()

# Funcion que prepara las variables para el nuevo estado y lanza el start
func _state_start() -> void:
	# print("StateMachine ", controlled_node.name, "start state ", current_state.name)
	
	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()

# Metodo para cambiar a un nuevo estado
func change_to(new_state: String) -> void:
	if current_state and current_state.has_method("end"): current_state.end()
	current_state = get_node(new_state)
	_state_start()

# Metodos que se ejecutan solos
func _process(delta: float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)

func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("on_physics_process"):
		current_state.on_physics_process(delta)

func _input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_input"):
		current_state.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_input"):
		current_state.on_unhandled_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_key_input"):
		current_state.on_unhandled_key_input(event)

func _on_timer_timeout() -> void:
	if current_state and current_state.has_method("on_timer_timeout"):
		current_state.on_timer_timeout()
