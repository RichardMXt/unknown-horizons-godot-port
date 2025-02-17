extends Node2D
## Inherited by all 2D buildings,
## it has all the parameters and functions that all buildings need

class_name Building2D

## Data resource for the building
@export var building_data: BuildingData
@export var info_tab_widget: PackedScene
@export var building_size: Vector2i = Vector2i(1, 1)

## To be overridden for functionality on inputs when the building is selected
func handle_context_input(_event: InputEvent):
  pass
