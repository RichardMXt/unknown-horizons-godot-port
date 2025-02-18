extends ProductionBuilding2D

class_name Smeltery2D

func _ready():
  self.setup_building()
  self.should_produce = true
