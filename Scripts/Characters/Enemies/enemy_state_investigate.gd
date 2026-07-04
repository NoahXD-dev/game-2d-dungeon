extends StateBase

func on_physics_process(_delta: float) -> void:
	# Si lo vuelve a ver mientras investigaba, regresa a persecución
	if controlled_node.check_vision():
		controlled_node.last_known_position = controlled_node.player.global_position
		state_machine.change_to("EnemyStateChase")
		return
		
	var agent = controlled_node.navigation_agent_2d
	agent.target_position = controlled_node.last_known_position
	
	if agent.is_navigation_finished():
		# Llegó y no hay nadie; regresa a patrullar de forma segura
		if controlled_node.waypoints.size() > 0:
			state_machine.change_to("EnemyStatePatrol")
			return
	
	# Avanzamos a la ultima posicion del jugador
	var next_pos = agent.get_next_path_position()
	var delta_pos = next_pos - controlled_node.global_position
	var distance = delta_pos.length()
	
	if distance <= controlled_node.stop_distance:
		controlled_node.set_movement_state(Vector2.ZERO)
		return
		
	var dir = delta_pos.normalized()
	controlled_node.set_movement_state(dir)
	controlled_node.velocity = dir * controlled_node.speed
	controlled_node.move_and_slide()
