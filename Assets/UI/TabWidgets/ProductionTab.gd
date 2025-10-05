extends PanelContainer

class_name ProductionTab

var selected_objects: Array = []: set = set_selected_objects

signal building_selected_changed

func set_selected_objects(new_selected_objects: Array) -> void:
  selected_objects = new_selected_objects
  building_selected_changed.emit()