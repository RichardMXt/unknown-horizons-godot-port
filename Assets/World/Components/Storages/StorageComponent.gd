@tool

extends BaseComponent

class_name StorageComponent

@export var load_or_unload_time: float = 2.0

## The storage of the building.[br]
## [b]Note[/b]: The [method SlotStorageComponent.set_storage_item_amount] function is to be used to set a key
@export var storage: Dictionary[StringName, int] = {} # Resource to count map

var action_set: BuildingActionSet

## a local signal emited when the storage changes
signal storage_changed(storage_state: BuildingActionSet.StorageStates)



func set_components(new_components: Array[BaseComponent]) -> void:
  for component in new_components:
    if component is BuildingActionSet:
      self.action_set = component

func get_storage_state() -> BuildingActionSet.StorageStates:
  return BuildingActionSet.StorageStates.EMPTY

## Used to set the storage amount of a specific resource.[br]
## The resource key will be created if it does not exist in the storage.[br]
func set_storage_item_amount(resource: StringName, new_amount: int) -> void:
  storage[resource] = max(new_amount, 0)
  var storage_state: BuildingActionSet.StorageStates = self.get_storage_state()
  self.storage_changed.emit(storage_state)
  GameStats.game_stats_resource.resources_changed.emit()

func get_storage_item_amount(resource: StringName) -> int:
  return self.storage.get(resource, 0)
