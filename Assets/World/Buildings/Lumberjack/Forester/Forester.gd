extends Unit2D

var closest_trees: Array = []

@export var choping_down_tree_time: float = 2
@export var speed_px_per_sec: float = 64

# Called when the node enters the scene tree for the first time.
func _ready():
  set_closest_trees()
  do_movment_loop()

func set_closest_trees():
  closest_trees = self.get_parent().get_parent().get_trees(false)
  if closest_trees.has(closest_trees[0]):
    pass
  closest_trees.sort_custom(is_first_tree_closer)

func is_first_tree_closer(first, second) -> bool:
  if self.global_position.distance_to(first) < self.global_position.distance_to(second):
    return true
  else:
    return false

func is_tree_available_for_choping(tree_pos: Vector2) -> bool:
  var tile_map_layer: TileMapLayerNavigation = self.get_parent().get_parent()
  var cell_data = tile_map_layer.get_cell_tile_data(tile_map_layer.local_to_map(tree_pos))
  var is_there_still_a_tree: bool = cell_data != null and cell_data.get_custom_data(tile_map_layer.is_tree)

  return is_there_still_a_tree and not tile_map_layer.trees_getting_choped.has(tree_pos)


func do_movment_loop():
  await wait_for_tree_in_need()

  var tree_pos = await go_to_tree()

  await chop_down_tree(tree_pos)

  await go_back_and_unload()

  do_movment_loop()

func wait_for_tree_in_need():
# wait until needs and can go to tree
  while self.get_parent().number_of_output_products >= self.get_parent().max_storage_capacity or closest_trees == []:
    await self.get_tree().create_timer(1).timeout

func go_to_tree() -> Vector2:
  self.visible = true
  var tree_pos: Vector2 = closest_trees.pop_front()
# if the tree is not good for choping( no tree at all, is already being choped, e.t.c.), go to another one
  while not is_tree_available_for_choping(tree_pos):
    tree_pos = closest_trees.pop_front()

# lock tree
  var tile_map_layer: TileMapLayerNavigation = self.get_parent().get_parent()
  tile_map_layer.trees_getting_choped[tree_pos] = null

# go to tree
  var tween_time = self.global_position.distance_to(tree_pos) / speed_px_per_sec
  var animation_name = self.get_animation_name(self.get_sprite_angle(tree_pos), CarrierState.Empty)
  self.person_sprite.play(animation_name)
  var move_tween: Tween = self.get_tree().create_tween().bind_node(self)
  move_tween.tween_property(self, "global_position", tree_pos, tween_time)
  await move_tween.finished
  self.person_sprite.stop()

  return tree_pos

func chop_down_tree(tree_pos):
  await self.get_tree().create_timer(choping_down_tree_time).timeout
  var tile_map_layer: TileMapLayerNavigation = self.get_parent().get_parent()
  tile_map_layer.set_cell(tile_map_layer.local_to_map(tree_pos), -1)
  tile_map_layer.trees_getting_choped.erase(tree_pos)

func go_back_and_unload():
  var hut_pos: Vector2 = self.get_parent().global_position
  var tween_time = self.global_position.distance_to(hut_pos) / speed_px_per_sec
  var move_tween: Tween = self.get_tree().create_tween().bind_node(self)
  var animation_name = self.get_animation_name(self.get_sprite_angle(hut_pos), CarrierState.WithFreight)
  move_tween.tween_property(self, "global_position", hut_pos, tween_time)
  self.person_sprite.play(animation_name)
  await move_tween.finished
  self.person_sprite.stop()
  #await self.move(CarrierState.WithFreight, path_back.duplicate())

  await self.get_parent().unload_wood()
  self.visible = false
