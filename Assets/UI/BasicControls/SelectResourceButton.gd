extends InventorySlot

class_name SelectResourceButton

func _process(_delta):
  if self.is_visible_in_tree():
    if self.resource_type:
      var resource_amount = GameStats.game_stats_resource.resources.get(resource_type)
      if resource_amount: # there might be no resource key yet because the it is created when the resource first is stored
        self.resource_amount = resource_amount
      else:
        self.resource_amount = 0