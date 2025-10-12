@tool

extends StorageComponent

class_name SizedStorageComponent

@export var limit: int = 10

func get_storage_state() -> BuildingActionSet.StorageStates:
  var storage_state: BuildingActionSet.StorageStates = BuildingActionSet.StorageStates.FULL
  if self.has_node(".."):
    var parent: WorldThing2D = self.get_parent() as WorldThing2D
    if parent == null:
      return BuildingActionSet.StorageStates.EMPTY
    
    # for each resource produced, check if not full in storage
    if parent is Building2D:
      var production_lines: Array[WorldThing2D] = parent.get_all_nodes_of_type(ProductionLineComponent) as Array[WorldThing2D]
      for production_line in production_lines:
        for produces in production_line.produces.keys():
          var max_amount = self.limit
          var current_amount = storage.get(produces, 0)
          if current_amount < max_amount:
            storage_state = BuildingActionSet.StorageStates.EMPTY
    elif parent is Collector:
      # if any resource is not 0
      if self.storage.values().reduce(func(sum, amount): return sum + amount, 0) as int <= 0:
        storage_state = BuildingActionSet.StorageStates.EMPTY
  
  return storage_state

func set_storage_item_amount(resource: StringName, new_amount: int) -> void:
  self.storage[resource] = clamp(new_amount, 0, limit)
  if self.storage[resource] == 0:
    self.storage.erase(resource)
  var storage_state := self.get_storage_state()
  self.storage_changed.emit(storage_state)
  GameStats.game_stats_resource.resources_changed.emit()
