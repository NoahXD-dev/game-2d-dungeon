extends StateBase

func start() -> void:
	controlled_node.set_movement_state(Vector2.ZERO)

func on_physics_process(_delta: float) -> void:
	# Si ve al jugador, persíguelo de inmediato
	if controlled_node.check_vision():
		controlled_node.last_known_position = controlled_node.player.global_position
		state_machine.change_to("EnemyStateChase")
		return


func on_timer_timeout() -> void:
	# El timer terminó, pasamos a patrullar al siguiente waypoint
	if controlled_node.waypoints.size() > 0:
		controlled_node.current_index = (controlled_node.current_index + 1) % controlled_node.waypoints.size()
		state_machine.change_to("EnemyStatePatrol")
