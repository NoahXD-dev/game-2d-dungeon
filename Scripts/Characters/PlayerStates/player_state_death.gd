extends StateBase

func start():
	controlled_node.player_collision_shape_2d.disabled = true
	controlled_node.hurt_collision_shape_2d.disabled = true
	
	# 1. Detener por completo el movimiento del enemigo para que acuse el golpe
	controlled_node.velocity = Vector2.ZERO
	
	# 3. Reproducir animación de herido (asegúrate de que NO tenga Loop en el editor)
	controlled_node.update_animation("death")
	
	# 4. Esperamos a que la animación termine
	await controlled_node.animated_sprite_2d.animation_finished
	
	controlled_node.queue_free()
