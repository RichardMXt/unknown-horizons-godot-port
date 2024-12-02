extends Node2D

class_name Warehouse2D

@export_category("WareHouse")
@export var game_name: String = "WareHouse"
@export var load_and_unload_time: float = 2
@export var max_loading_and_unloading_limit: int = 2

@onready var LoadUnloadTimer: Timer = get_node("LoadUnloadTimer")

signal slot_opened

#signal update_resources
var cur_loading_and_unloading: int = 0



func _ready():
  self.get_parent().register_building(self)



func loading_finished():
  cur_loading_and_unloading = max(cur_loading_and_unloading - 1, 0)
  slot_opened.emit()



func loading_started():
  cur_loading_and_unloading = min(cur_loading_and_unloading + 1, max_loading_and_unloading_limit)



func unload_worker(object: String, amount: int) -> int:
  #LoadUnloadTimer.start(load_and_unload_time / 2)
  #await LoadUnloadTimer.timeout

  if GameStats.game_stats_resource.resources.has(object):
    GameStats.game_stats_resource.resources[object] += amount
  else:
    GameStats.game_stats_resource.resources[object] = amount

  #update_resources.emit()
  print("the amount of %s is %s" % [object, GameStats.game_stats_resource.resources[object]])

  return 0



func load_worker(object: String, amount: int) -> int:
  #LoadUnloadTimer.start(load_and_unload_time / 2)
  #await LoadUnloadTimer.timeout

  if GameStats.game_stats_resource.resources.has(object):
    var max_available = min(amount, GameStats.game_stats_resource.resources[object])
    GameStats.game_stats_resource.resources[object] -= max_available
    #update_resources.emit()
    print("the amount of %s is %s" % [object, GameStats.game_stats_resource.resources[object]])
    return max_available
  else:
    print("the amount of %s is %s" % [object, GameStats.game_stats_resource.resources[object]])
    return 0
