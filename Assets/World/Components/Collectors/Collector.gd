@tool

extends BaseComponent

class_name Collector

class Job:
  static var NONE: Job = Job.new(ResourceConfig.Resources.NONE, 0, null, null)

  var resource: StringName
  var amount: int
  var building_from: Building2D
  var building_to: Building2D

  func _init(resource: StringName, amount: int, building_from: Building2D, building_to: Building2D):
    self.resource = resource
    self.amount = amount
    self.building_from = building_from
    self.building_to = building_to

const CollectorTypes: Dictionary[StringName, StringName] = {
  BUILDING_COLLECTOR   = &"BuildingCollector",
  NATURE_COLLECTOR     = &"NatureCollector",
}

@export var radius: int = 10

@onready var built_tilemap: BuiltTileMap = self.get_node("/root/Main/BuiltTileMap")
@onready var parent_building: Building2D = self.get_parent()

# var building_from: Building2D
# var building_to: Building2D

# var resource: StringName = ResourceConfig.Resources.NONE
# var amount: int = 0

var building_storage: SlotStorageComponent
var production_line_components: Array[ProductionLineComponent]

var storage: SizedStorageComponent
var move_by_cell: MoveByCellComponent
var action_set: BuildingActionSet


var collector_type: String = self.CollectorTypes.BUILDING_COLLECTOR:
  set(value):
    collector_type = value
    if self.move_by_cell:
      match self.collector_type:
        self.CollectorTypes.BUILDING_COLLECTOR:
          self.move_by_cell.allowed_movement = self.MoveByCellComponent.AllowedMovementTypes.MOVE_ON_ROAD
        self.CollectorTypes.NATURE_COLLECTOR:
          self.move_by_cell.allowed_movement = self.MoveByCellComponent.AllowedMovementTypes.MOVE_ON_LAND 

#region Editor: dynamic values for dropdown for `collector_type`
func _get_property_list() -> Array:
  return [
    {
      "name": "Collecter Type",
      "default": self.CollectorTypes.BUILDING_COLLECTOR,
      "type": TYPE_STRING,
      "hint": PROPERTY_HINT_ENUM,
      "hint_string": ",".join(self.CollectorTypes.keys()),
      "usage": PROPERTY_USAGE_DEFAULT,
    }
  ]

func _get(property_name):
  match property_name:
    "Collecter Type":
      return self.collector_type

func _set(property_name, val):
  match property_name:
    "Collecter Type":
      self.collector_type = val
#endregion



# func set_pause(value: bool) -> void:
#   super(value)
#   collecting_loop()



func _ready() -> void:
  var components: Array[BaseComponent] = []
  for node: Node in self.get_children():
    var component: BaseComponent = node as BaseComponent
    if component:
      components.append(component)
  
  for component in components:
    if component is SizedStorageComponent:
      self.storage = component
    if component is MoveByCellComponent:
      self.move_by_cell = component
    if component is BuildingActionSet:
      self.action_set = component
    component.set_components(components)

func set_components(new_components: Array[BaseComponent]) -> void:
  for component in new_components:
    if component is SlotStorageComponent:
      self.building_storage = component as SlotStorageComponent
    if component is ProductionLineComponent:
      self.production_line_components.append(component)
  if self.paused:
    await self.unpaused
  self.collecting_loop()



## Finds the closest building that produces the needed resource, Note: For now, we will only collect from production buildings and not warehouses
func get_building_to_collect_from(needed_resource: StringName) -> Building2D:
  if built_tilemap == null: # if the built tilemap is null, then return null
    return null
  var closest_building: Building2D = null # declare the closest building var to null
  var distance_to_building: int = 0 # declare the distance to the building
  for building in built_tilemap.building_position_to_building.values(): # loop through the buildings
    if building.is_resource_available(needed_resource): # if the building has the needed resource and it is its output,
      var path_to_building = move_by_cell.pathfinding.get_path_to_dest(self.global_position, building.global_position) # get the path to the building.
      if path_to_building != null and (closest_building == null or len(path_to_building) < distance_to_building): # if the building is closer than the last closest building,
        closest_building = building # set the closest building to the current building,
        distance_to_building = len(path_to_building) # and set the new distance to the building to collect from
  return closest_building

func get_path_to_closest_warehouse() -> Array[Vector2]:
  if built_tilemap == null: # if the built tilemap is null, then return null
    return []
  var path_to_warehouse: Array[Vector2] = []
  for building_position in built_tilemap.building_name_to_building_poses.get("Warehouse", []): # loop through the buildings
    var warehouse: Warehouse2D = self.built_tilemap.building_position_to_building.get(building_position, null) as Warehouse2D
    if warehouse: # if the building is a warehouse,
      var path_to_current_warehouse = move_by_cell.pathfinding.get_path_to_dest(self.global_position, warehouse.global_position) # get the path to the warehouse.
      if path_to_current_warehouse == null:
        continue
      if (path_to_warehouse == [] or len(path_to_current_warehouse) < len(path_to_warehouse)) and path_to_current_warehouse != null: # if the warehouse is closer than the last closest warehouse,
        path_to_warehouse = []
        for cell in path_to_current_warehouse:
          path_to_warehouse.append(cell as Vector2)
  return path_to_warehouse

## Returns the best possible job at the moment
func get_best_job() -> Job:
  if self.building_storage == null:
    return null
  var best_job: Job = null
  var job_score: int = 0
  for resource in self.building_storage.storage.keys():
    var carry_in: bool = true
    for production_line in self.production_line_components:
      if production_line.produces.has(resource):
        carry_in = false
        break
    
    if self.collector_type == self.CollectorTypes.NATURE_COLLECTOR and carry_in == false: # Nature Collector only collects
      continue

    var new_job: Job = Job.new(resource, 0, null, null)
    var amount_to_load: int = 0
    if carry_in:
      amount_to_load = self.building_storage.max_capacity[resource] - self.building_storage.storage[resource]
      new_job.building_to = self.parent_building
      var building_to_collect_from: WorldThing2D = self.get_building_to_collect_from(resource)
      if building_to_collect_from != null:
        new_job.building_from = building_to_collect_from
    else:
      var path_to_warehouse: Array[Vector2] = self.get_path_to_closest_warehouse()
      if path_to_warehouse == []:
        continue
      amount_to_load = self.building_storage.storage[resource]
      new_job.building_from = self.parent_building
      new_job.building_to = self.built_tilemap.building_position_to_building.get(path_to_warehouse[-1])

    new_job.amount = clamp(amount_to_load, 0, self.storage.limit)
    self.storage.set_storage_item_amount(resource, new_job.amount)
    if new_job.building_from == null or new_job.building_to == null or self.storage.storage.get(new_job.resource) == 0 or new_job.resource == ResourceConfig.Resources.NONE:
      continue
    var path_to_start = move_by_cell.pathfinding.get_path_to_dest(self.global_position, new_job.building_from.global_position)
    var path_to_end = move_by_cell.pathfinding.get_path_to_dest(new_job.building_from.global_position, new_job.building_to.global_position)
    if path_to_end == null or path_to_start == null or len(path_to_end) > self.radius:
      continue
    
    var storages: Array = new_job.building_to.get_components(StorageComponent)
    var amount_available = 0
    if new_job.building_to is Warehouse2D:
      amount_available = GameStats.game_stats_resource.resources.get(new_job.resource, 0)
    elif storages == []:
      continue
    else:
      amount_available = storages[0].storage.get(new_job.resource)
    var new_job_score: int = min(new_job.amount, amount_available + 2) - (len(path_to_start) + len(path_to_end) / 2) /2 
    if new_job_score > job_score or new_job == null:
      best_job = new_job
      job_score = new_job_score

  if best_job == null and self.built_tilemap.building_position_to_building.get(self.global_position) != self.parent_building:
    return Job.new(ResourceConfig.Resources.NONE, 0, self.parent_building, self.parent_building) # go home

  return best_job



## the loop for the collecting logic, called at start
func collecting_loop() -> void:
  while true:
    var job: Job = await self.wait_for_job()
    self.visible = true
    await self.move_by_cell.move(job.building_from.global_position)
    self.visible = false
    await self.load_resources(job)
    self.visible = true
    await self.move_by_cell.move(job.building_to.global_position)
    self.visible = false
    await self.unload_resources(job)

func wait_for_job() -> Job:
  var best_job: Job = self.get_best_job()
  while best_job == null:
    await GameStats.game_stats_resource.resources_changed
    if self.paused:
      await self.unpaused
    best_job = self.get_best_job()
  return best_job

func load_resources(job: Job) -> void:
  if job.building_from == null or job.building_from.is_queued_for_deletion():
    return
  if self.collector_type == self.CollectorTypes.NATURE_COLLECTOR:
    action_set.building_state = action_set.BuildingStates.WORK
    self.visible = true
  var amount_given: int = await job.building_from.load_resource(job.resource, self.storage.storage.get(job.resource, 0))
  if self.paused:
    await self.unpaused
  self.storage.set_storage_item_amount(job.resource, amount_given)
  var amount_taken: int = self.storage.storage.get(job.resource, 0)
  job.amount = amount_taken

func unload_resources(job: Job) -> void:
  if job.building_to == null or job.building_to.is_queued_for_deletion():
    return
  if self.collector_type == self.CollectorTypes.NATURE_COLLECTOR:
    action_set.building_state = action_set.BuildingStates.WORK
    self.visible = true
  await job.building_to.unload_resource(job.resource, self.storage.storage.get(job.resource, 0))
  if self.paused:
    await self.unpaused
  self.storage.storage = {}
