@tool
extends Node
class_name ColumnGenerator

const TILE_DATA: Dictionary = {
	"pillarSmall": { "source_id": 0, "atlas_coords": Vector2i(0, 2) }
}

@export var wall_generator: WallGenerator

@export_group("Tiles Maps")
@export var wall_tilemap_layer: TileMapLayer
@export var column_tilemap_layer: TileMapLayer

func _ready() -> void:
	if wall_generator and wall_generator.floor_generator:
		wall_generator.floor_generator.map_generated.connect(_on_floor_ready)
	else:
		generate_pillars()

func _on_floor_ready(_floor_cells: Array[Vector2i]) -> void:
	generate_pillars()

func generate_pillars() -> void:
	column_tilemap_layer.clear()
	
	var cardinals: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var floor_set: Dictionary = wall_generator._build_floor_set()
	var column_set: Dictionary = wall_generator._place_columns(floor_set, cardinals)
	
	if column_set.is_empty():
		return
	
	var pillar_small = TILE_DATA.pillarSmall
	for cell in column_set:
		column_tilemap_layer.set_cell(cell, pillar_small.source_id, pillar_small.atlas_coords)
