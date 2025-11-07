@tool

extends HBoxContainer
## Displays the resources needed to build a building, sets only the labels under the path "*child*/PanelContainer/BuildCostDisplay" 
## to the resource [code]child.name.trim_suffix("Display").to_snake_case().to_upper()"[/code]

class_name BuildingCostResourcesOverlay

func set_building_cost(cost: Dictionary[StringName, int]) -> void:
  for child in self.get_children():
    if child.has_node("PanelContainer/BuildCostDisplay"):
      var panel_container: PanelContainer = child.get_node("PanelContainer")
      var build_cost_display: LabelEx = child.get_node("PanelContainer/BuildCostDisplay")
      var resource: StringName = child.name.trim_suffix("Display").to_snake_case().to_upper()
      resource = ResourceConfig.Resources.get(resource, &"NONE")
      if cost.has(resource):
        build_cost_display.text = "-%s" % cost.get(resource)
        panel_container.visible = true
      else:
        panel_container.visible = false
