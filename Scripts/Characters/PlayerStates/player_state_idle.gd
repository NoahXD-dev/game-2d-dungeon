extends StateBase

func on_physics_process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_direction != Vector2.ZERO:
		state_machine.change_to("PlayerStateWalk")
		return
	
	controlled_node.update_animation("idle")
	controlled_node.velocity = Vector2.ZERO
	controlled_node.move_and_slide()
