extends Node2D

class_name Warehouse2D

@export_category("WareHouse")
@export var game_name: String = "WareHouse"

signal update_resources



func unload_person(amount: int, object: String):
  if GameStats.game_stats_resource.resources.has(object):
    GameStats.game_stats_resource.resources[object] += amount
  else:
    GameStats.game_stats_resource.resources[object] = amount
  update_resources.emit()



func load_person(amount: int, object: String):
  if GameStats.game_stats_resource.resources.has(object):
    var max_available = min(amount, GameStats.game_stats_resource.resources[object])
    GameStats.game_stats_resource.resources[object] -= max_available
    update_resources.emit()
    return max_available
  else:
    return null
