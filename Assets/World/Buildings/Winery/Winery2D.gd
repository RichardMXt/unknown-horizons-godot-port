extends ProductionBuilding2D

class_name Winery2D

func _ready():
  self.setup_building()
  self.should_produce = true