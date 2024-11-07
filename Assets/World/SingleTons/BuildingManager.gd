extends Node

var Farm = preload("res://Assets/World/Buildings/Agricultural/Farm2D/Farm2D.tscn")
var WareHouse = preload("res://Assets/World/Buildings/WareHouse2D/ware_house2D.tscn")

var building_name_to_building_poses: Dictionary = {}
var building_pos_to_building: Dictionary = {}
var building_to_build = null

signal new_building_builded



func get_building_to_build(pos):
  if building_to_build != null:
# check if space is ocupied
    if building_pos_to_building.has(pos):
      return null

    return building_to_build

  return null



func register_building(building):
  if building != null:
# register building to building poses
    building_pos_to_building[building.position] = building

# register building pos into building array
    var building_poses = building_name_to_building_poses.get(building.game_name)
    if building_poses != null:
      building_poses.append(building.position)
    else:
      building_name_to_building_poses[building.game_name] = [building.position]

# handle signals
    new_building_builded.emit(building.position)
    if building.game_name != "WareHouse":
      new_building_builded.connect(building.new_building_builded)



func new_building_to_build(building):
  building_to_build = building
