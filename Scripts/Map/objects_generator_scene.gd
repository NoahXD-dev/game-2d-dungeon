extends Node2D

@export var tilemap_layer_floor: TileMapLayer

@export_group("Coins")
@export var coin_scene: PackedScene
@export var coin_amount: int = 10

func _ready() -> void:
	generate_coins()

func generate_coins() -> void:
	# Obtiene solo las celdas que tienen tile
	var cells = tilemap_layer_floor.get_used_cells()
	
	if cells.is_empty():
		return
	
	cells.shuffle()
	var coins_created = 0
	for cell in cells:
		if coins_created >= coin_amount:
			break
		
		# Convierte la coordenada de celda a posición en el mundo
		var pos = tilemap_layer_floor.map_to_local(cell)
		var coin = coin_scene.instantiate()
		coin.position = pos
		add_child(coin)
		coins_created += 1
