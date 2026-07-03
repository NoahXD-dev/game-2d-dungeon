extends StateBase

func on_physics_process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_direction != Vector2.ZERO:
		state_machine.change_to("PlayerStateWalk")
		return
	
	print("color ", controlled_node.color)
	print("last_direction ", controlled_node.last_direction)
	controlled_node.animated_sprite_2d.play("idle_" + controlled_node.color + "_" + controlled_node.last_direction)
	controlled_node.velocity = Vector2.ZERO
	controlled_node.move_and_slide()
