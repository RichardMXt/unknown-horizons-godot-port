extends ProductionBuilding2D

class_name Warehouse2D

func _ready():
  self.setup_building()
  self.should_produce = true