extends ProductionBuilding2D

class_name StonePit2D

func _ready():
  self.setup_building()
  self.should_produce = true
