@tool

extends BaseComponent
## Collects needed resources from buildings and brings them to the parent building.

class_name BuildingCollectorComponent

## The sprite frames for the animation of the collector
@export var sprite_frames: SpriteFrames = preload("res://Assets/World/Components/Collectors/BuildingCollector/Sprites/BuildingCollectorFrames.tres"):
  set(value):
    sprite_frames = value
    if action_set == null:
      return
    action_set.sprite_frames = sprite_frames

@onready var move_by_cell: MoveByCellComponent = self.get_node("MoveByCellComponent")
@onready var action_set: CollectorActionSet = self.get_node("CollectorActionSet")

func _ready():
  # setup components
  var child_components: Array[BaseComponent] = []
  for component in self.get_children():
    child_components.append(component)
  for component in child_components:
    component.set_components(child_components)
  if action_set != null:
    action_set.sprite_frames = sprite_frames
