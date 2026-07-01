@tool
extends Node
class_name FloorGenerator

const TILE_DATA: Dictionary = {
	"floor": { "terrain_set": 0, "terrain": 0 }
}

signal map_generated(floor_cells: Array[Vector2i])

@export_group("Seed")
@export var gen_seed: int = 0
@export var randomize_seed: bool = true

@export_group("Map")
@export var map_dimensions: Vector2i = Vector2i(40, 40)
@export var boundary_padding: int = 4
@export var tilemap_layer: TileMapLayer

@export_group("Walker")
@export var walker_count: int = 3
@export var total_step: int = 600

@export_tool_button("Generate Map") var map_generate_button = generate_map

func _ready() -> void:
	generate_map()

func generate_map() -> void:
	if randomize_seed:
		gen_seed = randi()
	seed(gen_seed)
	tilemap_layer.clear()
	_run_walkers(map_dimensions, boundary_padding)
	call_deferred("emit_signal", "map_generated", tilemap_layer.get_used_cells())

# Pintamos el suelo de la cueva
func _run_walkers(dimensions: Vector2i, padding: int) -> void:
	var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	var center: Vector2i = Vector2i(dimensions.x / 2, dimensions.y / 2)
	var bounds: Rect2i = _get_bounds(dimensions, padding)
	var steps_per_walker: int = total_step / max(walker_count, 1)
	var painted_cells: Array[Vector2i] = []

	for _w in range(walker_count):
		var cur_pos := center
		for _i in range(steps_per_walker):
			if bounds.has_point(cur_pos):
				painted_cells.append(cur_pos)
			cur_pos = _step_walker(cur_pos, directions, bounds)
	
	var floor_data: Dictionary = TILE_DATA.floor
	tilemap_layer.set_cells_terrain_connect(
		painted_cells,
		floor_data.terrain_set,
		floor_data.terrain
	)

func _step_walker(pos: Vector2i, directions: Array, bounds: Rect2i) -> Vector2i:
	var next: Vector2i = pos + directions.pick_random()
	if bounds.has_point(next):
		return next
	var shuffled: Array[Vector2i] = directions.duplicate()
	shuffled.shuffle()
	for d in shuffled:
		if bounds.has_point(pos + d):
			return pos + d
	return pos  # Sin movimiento válido, se queda

func _get_bounds(dimensions: Vector2i, padding: int) -> Rect2i:
	var bounds: Rect2i = Rect2i(0, 0, dimensions.x, dimensions.y)
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		bounds = bounds.grow_side(side, -padding)
	return bounds
