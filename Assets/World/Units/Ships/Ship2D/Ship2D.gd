extends WorldThing2D

class_name Ship2D

@export var buoy: PackedScene = preload("res://Assets/World/Buoy/Buoy2D.tscn")
@export var ship_inventory: Dictionary[StringName, int] = {}
@export var valid_distance_for_building_harbor: int = 3

@onready var buoys: StaticBody2D = self.get_node("../Buoys")
@onready var terrain_tilemap: TerrainTileMap = self.get_node("../..") as TerrainTileMap
@onready var building_context: BuildingContext = self.get_node("/root/Main/GameContextManager/BuildingContext")

var move_by_cell: MoveByCellComponent = null

var is_selected: bool = false

signal buoy_added

func _ready():
  var child_components: Array[BaseComponent] = []
  for child in self.get_children():
    var component := child as BaseComponent
    if component != null:
      child_components.append(component)
  
  for component in child_components:
    component.set_components(child_components)
    component.paused = false
    var move_by_cell := component as MoveByCellComponent
    if move_by_cell != null:
      self.move_by_cell = move_by_cell

  movement_loop()
  CamUtils.center_if_no_camera(self)

func handle_context_input(event: InputEvent):
  if event is InputEventMouseButton:
    if event.pressed == true:
      if event.button_index == MOUSE_BUTTON_RIGHT:
        add_visit_point() # fire and forget

func selected(is_selected: bool) -> void:
  self.is_selected = is_selected

func add_visit_point():
  if self.is_selected == false or move_by_cell == null:
    return
  var mouse_pos: Vector2 = terrain_tilemap.get_global_mouse_position()
  var click_cell_position: Vector2i = terrain_tilemap.local_to_map(mouse_pos)
  var path_to_bouy = self.move_by_cell.pathfinding.get_path_to_dest(terrain_tilemap.local_to_map(self.global_position), click_cell_position, true, true)
  if self.move_by_cell.pathfinding.is_point_solid(click_cell_position) or path_to_bouy == null:
    return
  # if the shift key is not pressed, delete all buoys
  if not Input.is_key_pressed(KEY_SHIFT):
    for buoy in buoys.get_children():
      buoy.queue_free()
  # add a new buoy
  var buoy_inst: StaticBody2D = buoy.instantiate()
  buoys.add_child(buoy_inst)
  buoy_inst.global_position = terrain_tilemap.map_to_local(click_cell_position)
  self.move_by_cell.path = [] # stop action
  buoy_added.emit()

func movement_loop():
  while true:
    if self.move_by_cell == null:
      return
    if buoys.get_child_count() <= 0:
      await buoy_added
    var buoy = buoys.get_child(0)
    var ship_cell_position: Vector2i = terrain_tilemap.local_to_map(self.global_position)
    var buoy_cell_position: Vector2i = terrain_tilemap.local_to_map(buoy.global_position)
    var path = self.move_by_cell.pathfinding.get_path_to_dest(ship_cell_position, buoy_cell_position, true, true)
    await self.move_by_cell.move(path)
    # check if the buoy was not yet freed
    if buoy != null:
      ship_cell_position = terrain_tilemap.local_to_map(self.global_position)
      buoy_cell_position = terrain_tilemap.local_to_map(buoy.global_position)
      if ship_cell_position != buoy_cell_position:
        continue
      buoys.remove_child(buoy)
      buoy.queue_free()

func build_harbor():
  building_context.building_to_build = BuildingConfig.Buildings.WAREHOUSE
  building_context.reference_object = self

func is_tile_valid_for_building(tile: Vector2i) -> bool:
  var ship_tile_postition: Vector2i = terrain_tilemap.local_to_map(self.global_position)
  return ship_tile_postition.distance_to(tile) <= valid_distance_for_building_harbor
