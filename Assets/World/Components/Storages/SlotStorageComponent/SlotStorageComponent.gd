@tool

extends StorageComponent
## The slot storage component is used in buildings to store resources
##
## The slot storage component is a components storing resources in different slots below a certain amount

class_name SlotStorageComponent

## The capacity of the storage slots.
@export var max_capacity: Dictionary[StringName, int] = {} # resource_name to max_capacity

func _ready():
  # check if the max_capacity and storage dictionary is in the right format and have all the nessesary keys in the storage
  for resource in max_capacity.keys():
    if storage.has(resource) == false: # if the resource is not in the storage add it
      storage[resource] = 0

func get_storage_state() -> BuildingActionSet.StorageStates:
  var storage_state: BuildingActionSet.StorageStates = BuildingActionSet.StorageStates.FULL
  if self.has_node(".."):
    var parent: WorldThing2D = self.get_parent() as WorldThing2D
    if parent == null:
      return BuildingActionSet.StorageStates.EMPTY
    var production_lines: Array[WorldThing2D] = parent.get_all_nodes_of_type(ProductionLineComponent) as Array[WorldThing2D]
    
    # for each resource produced, check if not full in storage
    if parent is Building2D:
      for production_line in production_lines:
        for produces in production_line.produces.keys():
          var max_amount = max_capacity.get(produces, 0)
          var current_amount = storage.get(produces, 0)
          if current_amount < max_amount:
            storage_state = BuildingActionSet.StorageStates.EMPTY
    elif parent is Collector:
      if self.storage.values().reduce(func(sum, amount): return sum + amount, 0) as int <= 0:
        storage_state = BuildingActionSet.StorageStates.EMPTY
  
  return storage_state

## Used to set the storage amount of a specific resource.[br]
## The resource key will be created if it does not exist in the storage.[br]
func set_storage_item_amount(resource: StringName, new_amount: int) -> void:
  var max_amount = max_capacity.get(resource)
  if max_amount != null:
    self.storage[resource] = clamp(new_amount, 0, max_amount)
  else:
    self.storage[resource] = 0
    push_warning("The resource %s does not have a max capacity" % resource)
  if self.storage[resource] == 0:
    self.storage.erase(resource)
  var storage_state := self.get_storage_state()
  self.storage_changed.emit(storage_state)
  GameStats.game_stats_resource.resources_changed.emit()
