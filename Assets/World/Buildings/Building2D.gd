extends Node2D

class_name Building2D

@export_category("Farm")
@export var game_name: String = "Farm"
@export var production_time: int = 10
@export var max_storage_capacity: int = 10
@export var output_product: String
@export var needs_intake_poduct: bool = false

@onready var prod_timer: Timer = get_node("ProdTimer")
@onready var person: Person = get_node("Person")

var closest_warehouse_path: Array
var number_of_output_products = 0
var number_of_intake_products = 0



func _ready():
  var closest_warehouse_path_or_null = find_closest_warehouse()
  if closest_warehouse_path_or_null != null:
    closest_warehouse_path = closest_warehouse_path_or_null
    person.path = closest_warehouse_path
  prod_timer.start(production_time)



func new_building_builded(building_pos: Vector2):
  if BuildingManager.building_pos_to_building.get(building_pos).game_name == "WareHouse":
    var path_to_warehouse = self.get_parent().get_path_to_dest(self.position, building_pos)
    if (path_to_warehouse != null and len(path_to_warehouse) < len(closest_warehouse_path)) or len(closest_warehouse_path) == 0:
      closest_warehouse_path = path_to_warehouse
      person.path = closest_warehouse_path



func find_closest_warehouse():
  var warehouse_poses = BuildingManager.building_name_to_building_poses.get("WareHouse")

  if warehouse_poses == null:
    return null
  
  var closest_warehouse_path_yet = null
  for warehouse_pos in warehouse_poses:
    var warehouse_path = self.get_parent().get_path_to_dest(self.position, warehouse_pos)
    if warehouse_path == null:
      continue

    if closest_warehouse_path_yet == null or len(warehouse_path) < len(closest_warehouse_path_yet):
      closest_warehouse_path_yet = warehouse_path

  return closest_warehouse_path_yet



func _on_prod_timer_timeout():
  if needs_intake_poduct:
    if number_of_intake_products > 0:
      number_of_intake_products -= 1
    else:
      return

  if number_of_output_products < 10:
    number_of_output_products += 1
    

  if not person.is_moving:
    var amount_to_load = min(number_of_output_products - person.objects_carring["there"][1], person.max_carry_limit)
    person.objects_carring["there"] = [output_product, amount_to_load + person.objects_carring["there"][1]]
    if not needs_intake_poduct:
      person.objects_carring["back"] = null
    number_of_output_products -= amount_to_load
    person.move()
