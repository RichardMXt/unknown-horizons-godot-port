extends HBoxContainer

class_name FinanceAndResourceOverlay

@onready var balance_info_button: BalanceInfoButton = %BalanceInfoButton
@onready var resources_overlay: ResourceOverlay = %ResourcesOverlay

var building_context: BuildingContext = null

func on_context_changed(context: BaseContext) -> void:
  var building := &""
  var road_building_context := context as BuildingRoadContext
  var new_context_as_building_context := context as BuildingContext
  if self.building_context == null: # remember the building context
    self.building_context = new_context_as_building_context

  if road_building_context != null:
    building = &"TRAIL" # trail toggled, set name as trail

  if new_context_as_building_context != null:
    if self.building_context.building_changed.is_connected(self.on_building_changed) == false:
      self.building_context.building_changed.connect(self.on_building_changed)
    building = self.building_context.building_to_build
  elif self.building_context != null: # if the context is not the building context disconnect the update signal
    self.building_context.building_changed.disconnect(self.on_building_changed)

  if building != &"":
    balance_info_button.show_building_cost_overlay(building)
    resources_overlay.show_building_cost_overlay(building)
  else: # if there is no building(other context was set) toggle default overlays
    balance_info_button.show_normal_overlay()
    resources_overlay.show_normal_overlay()
    return

func on_building_changed(building: StringName) -> void:
  self.balance_info_button.show_building_cost_overlay(building)
  self.resources_overlay.show_building_cost_overlay(building)
