extends ProductionBuilding2D

class_name Lumberjack2D

@export var unload_wood_time: int = 2

func _ready():
  self.setup_building()
  self.input_product_storage["wood"] = 0
  production_loop()

func production_loop():
  while true:
    await wait_for_storage_space()
    await wait_for_wood()
    await produce_wood()

func wait_for_storage_space():
  while self.number_of_output_products >= self.building_data.max_storage_capacity:
    await self.get_tree().create_timer(1).timeout

func wait_for_wood():
  while self.input_product_storage["wood"] <= 0:
    await self.get_tree().create_timer(1).timeout

func produce_wood():
  if self.input_product_storage["wood"] > 0:
    self.production_timer = self.get_tree().create_timer(self.building_data.processing_time)
    await self.production_timer.timeout
    production_timer = null
    self.input_product_storage["wood"] -= 1
    self.number_of_output_products += 1
    self.show_tooltip_animation(1) # fire and forget

func unload_wood():
  await self.get_tree().create_timer(unload_wood_time).timeout
  self.input_product_storage["wood"] += 1
