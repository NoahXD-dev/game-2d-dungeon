@tool
extends Node
class_name WallGenerator

const TILE_DATA: Dictionary = {
	# Paredes Externas
	"wall" : { "terrain_set": 0, "terrain": 1 },
	# Columnas
	"column": { "source_id": 2, "atlas_coords": Vector2i(9, 3) },
}

@export var floor_tilemap_layer: TileMapLayer
@export var wall_tilemap_layer: TileMapLayer
@export var floor_generator: FloorGenerator

func _ready() -> void:
	if floor_generator:
		floor_generator.map_generated.connect(_on_floor_ready)
	else:
		generate_walls()

func _on_floor_ready(_floor_cells: Array[Vector2i]) -> void:
	generate_walls()

# Funcion principal
func generate_walls() -> void:
	wall_tilemap_layer.clear()
	
	var cardinals: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var floor_set: Dictionary = _build_floor_set()
	
	_fill_background(floor_set)
	
	var column_set: Dictionary = _place_columns(floor_set, cardinals)
	
	_place_walls(floor_set, column_set)

# Llenar todo el mapa con el terreno de muros
func _fill_background(floor_set: Dictionary) -> void:
	var wall_data: Dictionary = TILE_DATA.wall
	var all_cells: Array[Vector2i] = []
	var dimensions: Vector2i = floor_generator.map_dimensions
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var cell: Vector2i = Vector2i(x, y)
			if not floor_set.has(cell):
				all_cells.append(cell)
	
	wall_tilemap_layer.set_cells_terrain_connect(
		all_cells,
		wall_data.terrain_set,
		wall_data.terrain
	)

# Construir mapa de tiles del piso
func _build_floor_set() -> Dictionary:
	var floor_set: Dictionary = {}
	for cell in floor_tilemap_layer.get_used_cells():
		floor_set[cell] = true
	return floor_set

# Marcar espacios para las columnas
func _place_columns(floor_set: Dictionary, cardinals: Array[Vector2i]) -> Dictionary:
	var column_set: Dictionary = {}
	for cell in floor_set:
		for dir in cardinals:
			var candidate: Vector2i = cell + dir
			
			if floor_set.has(candidate):
				continue
			
			var all_floor: bool = true
			for neighbor_dir in cardinals:
				if not floor_set.has(candidate + neighbor_dir):
					all_floor = false
					break
			
			if all_floor:
				var tile: Dictionary = TILE_DATA.column
				wall_tilemap_layer.set_cell(candidate, tile.source_id, tile.atlas_coords)
				column_set[candidate] = true
	return column_set

# Pintar las paredes
func _place_walls(floor_set: Dictionary, column_set: Dictionary) -> void:
	var wall_cells: Array[Vector2i] = []
	var all_directions: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i(-1, -1), Vector2i( 1, -1), Vector2i(-1,  1), Vector2i( 1,  1)
	]
	for cell in floor_set:
		for dir in all_directions:
			var neighbor: Vector2i = cell + dir
			
			if not floor_set.has(neighbor) and not column_set.has(neighbor):
				wall_cells.append(neighbor)
	
	# Eliminar duplicados
	var unique_cells: Array[Vector2i] = []
	var seen: Dictionary = {}
	for cell in wall_cells:
		if not seen.has(cell):
			seen[cell] = true
			unique_cells.append(cell)
	
	var wall_data: Dictionary = TILE_DATA.wall
	wall_tilemap_layer.set_cells_terrain_connect(
		unique_cells,
		wall_data.terrain_set,
		wall_data.terrain
	)
