extends StateBase

func start():
	# 1. Detener por completo el movimiento del enemigo para que acuse el golpe
	controlled_node.set_movement_state(Vector2.ZERO)
	
	# 2. Forzar la última posición conocida del jugador (sabemos quién nos pegó)
	if controlled_node.player:
		controlled_node.last_known_position = controlled_node.player.global_position
	
	# 3. Reproducir animación de herido (asegúrate de que NO tenga Loop en el editor)
	controlled_node.play_animation("hurt")
	
	# 4. Esperamos a que la animación termine
	await controlled_node.animated_sprite_2d.animation_finished
	await controlled_node.get_tree().create_timer(0.1).timeout
	
	# 5. Volvemos a la carga: como sabemos dónde está el jugador, pasamos a EnemyStateChase
	if controlled_node.waypoints.size() > 0:
		state_machine.change_to("EnemyStatePatrol")
		return
	
	state_machine.change_to("EnemyStateChase")

func on_physics_process(delta: float) -> void:
	# Reducimos gradualmente el empuje hacia cero usando fricción (linear_interpolate / move_toward)
	controlled_node.knockback_velocity = controlled_node.knockback_velocity.move_toward(Vector2.ZERO, controlled_node.knockback_friction * delta)
	
	# Aplicamos el empuje al movimiento físico del CharacterBody2D
	controlled_node.velocity = controlled_node.knockback_velocity
	controlled_node.move_and_slide()
