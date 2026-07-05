extends StateBase

func start():
	# 1. Detener por completo el movimiento del enemigo para que acuse el golpe
	controlled_node.set_movement_state(Vector2.ZERO)
	
	# 3. Reproducir animación de herido (asegúrate de que NO tenga Loop en el editor)
	controlled_node.play_animation("death")
	
	# 4. Esperamos a que la animación termine
	await controlled_node.animated_sprite_2d.animation_finished
	
	controlled_node.queue_free()
