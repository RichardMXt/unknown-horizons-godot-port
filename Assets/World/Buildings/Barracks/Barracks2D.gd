extends ProductionBuilding2D

class_name Barracks2D

func _ready():
  self.setup_building()
  self.should_produce = true
