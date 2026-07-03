extends StateBase

func on_physics_process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_direction == Vector2.ZERO:
		state_machine.change_to("PlayerStateIdle")
		return
	
	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			controlled_node.last_direction = "right"
		else:
			controlled_node.last_direction = "left"
	else:
		if input_direction.y > 0:
			controlled_node.last_direction = "down"
		else:
			controlled_node.last_direction = "up"
	
	controlled_node.animated_sprite_2d.play("walk_" + controlled_node.color + "_" + controlled_node.last_direction)
	controlled_node.velocity = input_direction * controlled_node.speed
	controlled_node.move_and_slide()
