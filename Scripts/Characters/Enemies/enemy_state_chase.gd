extends StateBase

func on_physics_process(_delta: float) -> void:
	# Verificación constante de visión
	if controlled_node.check_vision():
		controlled_node.last_known_position = controlled_node.player.global_position
	else:
		# Perdió de vista al jugador, va a investigar la última posición
		state_machine.change_to("EnemyStateInvestigate")
		return
	
	var agent = controlled_node.navigation_agent_2d
	agent.target_position = controlled_node.player.global_position
	
	if agent.is_navigation_finished():
		controlled_node.set_movement_state(Vector2.ZERO)
		return
	
	# Avanzamos al siguiente punto por donde paso el jugador
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
