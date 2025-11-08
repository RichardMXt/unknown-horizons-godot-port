extends HBoxContainer

class_name FinanceAndResourceOverlay

@onready var balance_info_button: BalanceInfoButton = %BalanceInfoButton
@onready var resources_overlay: ResourceOverlay = %ResourcesOverlay

func on_context_changed(context: BaseContext) -> void:
  var building: StringName = &""
  var road_building_context: BuildingRoadContext = context as BuildingRoadContext
  var building_context: BuildingContext = context as BuildingContext
  if road_building_context != null:
    building = &"TRAIL" # trail toggled, set name as trail
  elif building_context != null:
    building = building_context.building_to_build
  else: # turn of building cost overlay if not building or road building contexts
    balance_info_button.show_normal_overlay()
    resources_overlay.show_normal_overlay()
    return

  if building != &"":
    balance_info_button.show_building_cost_overlay(building)
    resources_overlay.show_building_cost_overlay(building)
