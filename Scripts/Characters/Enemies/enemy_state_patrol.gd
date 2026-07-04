extends StateBase

func start() -> void:
	if controlled_node.waypoints.size() == 0:
		state_machine.change_to("EnemyStateIdle")
		return
	
	# CONFIGURAMOS EL DESTINO AQUÍ, justo al iniciar el estado
	var current_waypoint = controlled_node.waypoints[controlled_node.current_index]
	controlled_node.navigation_agent_2d.target_position = current_waypoint.global_position

func on_physics_process(_delta: float) -> void:
	# Si lo ve mientras patrulla, regresa a persecución
	if controlled_node.check_vision():
		controlled_node.last_known_position = controlled_node.player.global_position
		state_machine.change_to("EnemyStateChase")
		return
		
	var agent = controlled_node.navigation_agent_2d
	
	# Si llegamos a uno de los puntos, se espera un momento
	if agent.is_navigation_finished():
		controlled_node.timer.start()
		state_machine.change_to("EnemyStateIdle")
		return
	
	# Avanzamos al siguiente punto
	var next_pos = agent.get_next_path_position()
	var delta_pos = next_pos - controlled_node.global_position
	var dir = delta_pos.normalized()
	
	controlled_node.set_movement_state(dir)
	controlled_node.velocity = dir * controlled_node.speed
	controlled_node.move_and_slide()
