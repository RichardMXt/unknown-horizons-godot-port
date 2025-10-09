@tool

extends Collector

class_name LumberjackCollector

class Job:
  var resource: StringName
  var amount: int
  var from: Vector2i
  var to: Vector2i

  func _init(resource: StringName, amount: int, from: Vector2i, to: Vector2i):
    self.resource = resource
    self.amount = amount
    self.from = from
    self.to = to

@export var choping_time: float = 2



func get_best_job_for_lumberjack() -> Job:
  var best_job: Job = null
  var best_job_score: int = 0
  for tree in self.built_tilemap.get_trees():
    var tree_global_position: Vector2 = self.built_tilemap.to_global(self.built_tilemap.map_to_local(tree))
    if self.built_tilemap.trees_getting_choped.has(tree):
      continue
    var new_job = Job.new(ResourceConfig.Resources.WOOD, 0, tree_global_position, self.parent_building.global_position)
    var path_to_tree = self.move_by_cell.pathfinding.get_path_to_dest(self.global_position, tree, true, true)
    var path_back = self.move_by_cell.pathfinding.get_path_to_dest(tree, self.global_position, true, true)
    if path_to_tree == null or path_back == null or len(path_to_tree) > self.radius:
      continue
    var new_job_score: int = 1-(len(path_to_tree) + len(path_back))/radius/2
    if new_job_score > best_job_score:
      best_job = new_job
      best_job_score = new_job_score
  return best_job

func lock_tree(tree_pos: Vector2) -> void:
  built_tilemap.trees_getting_choped[tree_pos] = null

func is_cell_a_tree(tree_pos: Vector2) -> bool:
  var tile_map_layer: BuiltTileMap = built_tilemap
  var cell_data = tile_map_layer.get_cell_tile_data(tile_map_layer.local_to_map(tree_pos))
  return cell_data != null and cell_data.get_custom_data(tile_map_layer.is_tree)



func collecting_loop() -> void:
  while true:
    var job: Job = await self.wait_for_job()
    self.lock_tree(job.from)
    self.visible = true
    await self.move_by_cell.move(job.from)
    self.visible = false
    await self.chop_tree(job)
    self.visible = true
    await self.move_by_cell.move(job.to)
    self.visible = false
    await self.unload_tree(job)

func wait_for_job():
  var best_job: Job = self.get_best_job_for_lumberjack()
  while best_job == null:
    await GameStats.game_stats_resource.resources_changed
    if self.paused:
      await self.unpaused
    best_job = self.get_best_job_for_lumberjack()
  return best_job

func chop_tree(job: Job) -> void:
  await self.sleep(self.choping_time)
  if self.paused:
    await self.unpaused
  if not self.is_cell_a_tree(job.from):
    return
  var tile_map_layer: BuiltTileMap = built_tilemap
  tile_map_layer.set_cell(tile_map_layer.local_to_map(job.from), -1)
  self.storage.set_storage_item_amount(ResourceConfig.Resources.WOOD, 1)
  job.amount = self.storage.storage.get(ResourceConfig.Resources.WOOD, 0)
  tile_map_layer.trees_getting_choped.erase(job.from)

func unload_tree(job: Job) -> void:
  await self.sleep(self.building_storage.load_or_unload_time)
  if self.paused:
    await self.unpaused
  self.building_storage.set_storage_item_amount(ResourceConfig.Resources.WOOD, job.amount + self.building_storage.storage.get(ResourceConfig.Resources.WOOD, 0))
  self.storage.set_storage_item_amount(ResourceConfig.Resources.WOOD, 0)
  job.amount = 0