extends Node2D

@export var total_enemies = 3
@export var tilemap_layer_floor: TileMapLayer
@export var enemy_scene: PackedScene

func _ready() -> void:
	# Esperamos un frame para asegurarnos de que el mapa de tiles esté completamente cargado en memoria
	await get_tree().process_frame
	spawn_enemies()

func spawn_enemies() -> void:
	# 1. Obtenemos un array con las coordenadas (Vector2i) de todos los tiles pintados en esta capa
	var used_cells: Array[Vector2i] = tilemap_layer_floor.get_used_cells()
	
	# Seguridad: Si el tilemap está vacío, evitamos un bucle infinito o crash
	if used_cells.size() == 0:
		push_warning("¡El TileMapLayer de suelo está vacío! No se pueden spawnear enemigos.")
		return
	
	# 2. Bucle para instanciar la cantidad de enemigos que queremos
	for i in range(total_enemies):
		# Elegimos un índice al azar del array de celdas usadas
		var random_index: int = randi() % used_cells.size()
		var random_cell: Vector2i = used_cells[random_index]
		
		# 3. Convertimos la coordenada del Tile (ej: x:5, y:10) a posición local de píxeles (ej: x:160, y:320)
		var tile_local_pos: Vector2 = tilemap_layer_floor.map_to_local(random_cell)
		
		# 4. Convertimos esa posición local a posición Global del mundo para que no importe dónde esté el TileMap
		var tile_global_pos: Vector2 = tilemap_layer_floor.to_global(tile_local_pos)
		
		# 5. Instanciamos el enemigo
		var new_enemy = enemy_scene.instantiate()
		
		# Asignamos la posición global al enemigo
		new_enemy.global_position = tile_global_pos
		
		# 6. Lo añadimos a la escena. 
		# Es mejor agregarlo como hijo del "owner" (la escena principal) o de un nodo de entidades 
		# para que no herede transformaciones raras si el generador se mueve.
		get_parent().add_child.call_deferred(new_enemy)
		
		print("Enemigo ", i + 1, " generado en la celda: ", random_cell, " (Posición: ", tile_global_pos, ")")
