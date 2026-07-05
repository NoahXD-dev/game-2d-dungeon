extends StateBase

func start():
	controlled_node.velocity = Vector2.ZERO
	
	controlled_node.update_animation("hurt")
	
	await controlled_node.animated_sprite_2d.animation_finished
	
	state_machine.change_to("PlayerStateIdle")

func on_physics_process(delta: float) -> void:
	# Reducimos gradualmente el empuje hacia cero usando fricción (linear_interpolate / move_toward)
	controlled_node.knockback_velocity = controlled_node.knockback_velocity.move_toward(Vector2.ZERO, controlled_node.knockback_friction * delta)
	
	# Aplicamos el empuje al movimiento físico del CharacterBody2D
	controlled_node.velocity = controlled_node.knockback_velocity
	controlled_node.move_and_slide()
