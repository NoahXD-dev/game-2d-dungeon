extends StateBase

func start():
	controlled_node.update_animation("attack")
	
	controlled_node.hit_collision_shape_2d.disabled = false
	
	if controlled_node.last_direction == "down":
		controlled_node.hit_collision_shape_2d.position = Vector2(3, 11)
	elif controlled_node.last_direction == "up":
		controlled_node.hit_collision_shape_2d.position = Vector2(-4, -19)
	elif controlled_node.last_direction == "right":
		controlled_node.hit_collision_shape_2d.position = Vector2(16, 0)
	elif controlled_node.last_direction == "left":
		controlled_node.hit_collision_shape_2d.position = Vector2(-17, 0)
	
	await controlled_node.animated_sprite_2d.animation_finished
	state_machine.change_to("PlayerStateIdle")

func end():
	controlled_node.hit_collision_shape_2d.disabled = true
	controlled_node.hit_collision_shape_2d.position = Vector2.ZERO
