@tool

extends BaseComponent

class_name StorageComponent

enum StorageStates {
  EMPTY = 0,
  FULL  = 1,
  ## Leave state same
  KEEP  = 2
}

@export var load_or_unload_time: float = 2.0

## The storage of the building.[br]
## [b]Note[/b]: The [method SlotStorageComponent.set_storage_item_amount] function is to be used to set a key
@export var storage: Dictionary[StringName, int] = {} # Resource to count map

@export var state: StorageStates = StorageStates.EMPTY:
  set(value):
    if value == StorageStates.KEEP:
      return
    state = value
    update_action_set()

var action_set: BuildingActionSet



func set_components(new_components: Array[BaseComponent]) -> void:
  for component in new_components:
    if component is BuildingActionSet:
      self.action_set = component

func update_action_set() -> void:
  if self.action_set:
    var current_action_set_state_parts: PackedStringArray = BuildingActionSet.BuildingStates.find_key(self.action_set.building_state).split("_")
    var storage_state: String = StorageStates.find_key(self.state) # suffix

    var new_action_set_state_parts: PackedStringArray = current_action_set_state_parts
    if current_action_set_state_parts[-1] == "FULL":
      # if has a part in the animation name, change it
      new_action_set_state_parts[-1] = storage_state
    else: # else: add it
      new_action_set_state_parts.append(storage_state)
    if self.state == StorageStates.EMPTY: # no action state modifier
      new_action_set_state_parts.resize(len(new_action_set_state_parts) - 1) # delete suffix
    var action_set_new_state: StringName = "_".join(new_action_set_state_parts)
    if BuildingActionSet.BuildingStates.has(action_set_new_state):
      self.action_set.building_state = BuildingActionSet.BuildingStates[action_set_new_state]
    else:
      push_warning("Action set state not found: " + action_set_new_state)

## Used to set the storage amount of a specific resource.[br]
## The resource key will be created if it does not exist in the storage.[br]
func set_storage_item_amount(resource: StringName, new_amount: int, state: StorageStates = StorageStates.KEEP):
  storage[resource] = max(new_amount, 0)
  self.state = state
  GameStats.game_stats_resource.resources_changed.emit()

func get_storage_item_amount(resource: StringName) -> int:
  return self.storage.get(resource, 0)
