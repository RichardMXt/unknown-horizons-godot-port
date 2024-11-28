extends ProductionBuilding2D

class_name Farm2D

#@export_category("Farm2D")
@export var production_time: int = 10



func _ready():
  #var path = self.get_parent().get_path_to_dest(self.position, Vector2(0, 0))
  #if path != null:
    #self.carrier.path = path
  self.building_setup()
  prod_timer.start(production_time)



func _on_prod_timer_timeout():
  if self.needs_intake_product:
    if self.number_of_intake_products > 0:
      self.number_of_intake_products -= 1
    else:
      return

  if self.number_of_output_products < 10:
    self.number_of_output_products += 1

  var objects_to_carry: Dictionary = {"to_warehouse": ["", 0], "back": null}
  if not carrier.is_moving or len(closest_warehouse_path) > 0:
    var amount_to_load = min(number_of_output_products - carrier.objects_carring.get("to_warehouse")[1], carrier.max_carry_limit)
    objects_to_carry["to_warehouse"] = [output_product, amount_to_load + objects_to_carry["to_warehouse"][1]]

    if input_product == "":
      objects_to_carry["back"] = null
    else:
      objects_to_carry["back"] = min(max_storage_capacity - number_of_intake_products, carrier.max_carry_limit)

    resource_produced.emit(objects_to_carry, output_product, 1)
