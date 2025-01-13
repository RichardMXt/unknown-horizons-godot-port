extends Node
#
#var Farm2D = preload("res://Assets/World/Buildings/Agricultural/Farm2D/Farm2D.tscn")
#var WareHouse = preload("res://Assets/World/Buildings/WareHouse2D/ware_house2D.tscn")

var building_to_build = null

const road = "road"

enum Buildings {
  farm =       1,
  warehouse =  2,
  cattle_run = 3,
  lumberjack = 4,
}

func _input(event: InputEvent) -> void:
  var build_building_name := ""

  if event.is_action_pressed("toggle_build_building"):
    build_building_name = event.get_meta("building_name")
    if build_building_name == null or build_building_name== "":
      push_error("`toggle_build_building` action is pressed, but `building_name` meta is null or empty.")

  if event.is_action_pressed("toggle_build_road"):
    build_building_name = "road"
    
  if build_building_name:
    print_debug(event, ", building_name: ", build_building_name);
    if (build_building_name != null):
      set_building_to_build(build_building_name)


func set_building_to_build(building):
  building_to_build = building



func get_building_id(building_name: String) -> int:
  return Buildings.get(building_name)
