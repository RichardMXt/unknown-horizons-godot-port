@tool

extends StorageComponent

class_name SizedStorageComponent

@export var limit: int = 10

func set_storage_item_amount(resource: StringName, new_amount: int, state: StorageStates = StorageStates.KEEP):
  self.storage[resource] = clamp(new_amount, 0, limit)
  self.state = state
  GameStats.game_stats_resource.resources_changed.emit()
