@tool

extends BaseComponent
## Moves the an object by cells
##
## The component moves the object given by the node path(usualy the parent) by cells.

class_name MoveByCellComponent

## The speed of the object in tiles per second
@export var tile_per_sec: float = 2
## The type of allowed movement
@export var allowed_movement: AllowedMovementTypes = AllowedMovementTypes.MOVE_ON_ROAD:
  set(value):
    allowed_movement = value
    if pathfinding_node == null:
      push_warning("Pathfinding node is not found")
    else:
      match allowed_movement:
        AllowedMovementTypes.MOVE_ON_WATER:
          pathfinding = pathfinding_node.ship_pathfinding
        AllowedMovementTypes.MOVE_ON_ROAD:
          pathfinding = pathfinding_node.road_pathfinding
        AllowedMovementTypes.MOVE_ON_LAND:
          pathfinding = pathfinding_node.land_pathfinding

## The object this component is moving[br]
## Default: ".."
@export var object_to_be_moved: Node2D = null
## The pathfinding node[br]
## Default: "root/Main/Pathfinding"
@export var pathfinding_node: Pathfinding = null

## The possible types for determining if movement is allowed
enum AllowedMovementTypes {
  ## The value representing movement allowed on water
  MOVE_ON_WATER,
  ## The value representing movement allowed only on road
  MOVE_ON_ROAD,
  ## The value representing movement allowed on all land tiles
  MOVE_ON_LAND,
}

var action_set: BuildingActionSet = null

var pathfinding: PathFindingManagement2D = null

func _ready():
  if object_to_be_moved == null:
    object_to_be_moved = self.get_node("..")
  if pathfinding_node == null:
    pathfinding_node = self.get_node("/root/Main/Pathfinding")
  if pathfinding_node == null:
    push_warning("Pathfinding node is not found")
  else:
    match allowed_movement:
      AllowedMovementTypes.MOVE_ON_WATER:
        pathfinding = pathfinding_node.ship_pathfinding
      AllowedMovementTypes.MOVE_ON_ROAD:
        pathfinding = pathfinding_node.road_pathfinding
      AllowedMovementTypes.MOVE_ON_LAND:
        pathfinding = pathfinding_node.land_pathfinding

func set_components(components: Array[BaseComponent]):
  for component in components:
    if component is BuildingActionSet:
      action_set = component

func update_action_set(direction: int, state: BuildingActionSet.BuildingStates = BuildingActionSet.BuildingStates.IDLE) -> void:
  if self.action_set:
    var orientation = BuildingActionSet.Orientations.find_key(direction)
    if orientation == null:
      orientation = BuildingActionSet.Orientations._045
    self.action_set.orientation = orientation as BuildingActionSet.Orientations
    var current_action_set_state_parts: PackedStringArray = BuildingActionSet.BuildingStates.find_key(self.action_set.building_state).split("_")
    var move_state: String = BuildingActionSet.BuildingStates.find_key(state) # prefix, MOVE/IDLE
    
    var new_action_set_state_parts: PackedStringArray = current_action_set_state_parts
    if current_action_set_state_parts[0] in ["MOVE", "IDLE"]:
      # if already has a part in the animation name, change it
      new_action_set_state_parts[0] = move_state
    else: # else: add it
      new_action_set_state_parts.insert(0, move_state)
    var new_action_set_state: StringName = "_".join(new_action_set_state_parts)
    if BuildingActionSet.BuildingStates.has(new_action_set_state):
      self.action_set.building_state = BuildingActionSet.BuildingStates[new_action_set_state]
    else:
      push_warning("Action set state not found: " + new_action_set_state)

func move(path: Array[Vector2i]) -> void:
  if pathfinding == null:
    push_error("Pathfinding is not set and the object is wanted to be moved")
    return
  
  if path != null:
    var direction: int = 90
    self.object_to_be_moved.visible = true
    if self.pathfinding.tile_map_layer.local_to_map(object_to_be_moved.global_position) != path.pop_front(): # remove the starting position because the object is already there
      push_error("The path does not start from the current position")
    for new_position in path:
      var move_vec: Vector2 = self.pathfinding.tile_map_layer.map_to_local(new_position) - object_to_be_moved.global_position

      direction = snappedi(rad_to_deg(move_vec.angle_to(Vector2.RIGHT)), 45)
      direction = posmod(direction, 360) # make in range of 0-359
      self.update_action_set(direction, BuildingActionSet.BuildingStates.MOVE)

      
      var move_tween: Tween = self.get_tree().create_tween().bind_node(self)
      move_tween.tween_property(object_to_be_moved, "global_position", self.pathfinding.tile_map_layer.map_to_local(new_position), 1/tile_per_sec)
      await move_tween.finished
      if paused:
        await self.unpaused
    self.update_action_set(direction, BuildingActionSet.BuildingStates.IDLE)
