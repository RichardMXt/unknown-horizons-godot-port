@tool
extends VBoxContainer

## Used for the WidgetDetail element. Shouldn't be modified or used elsewhere.

## Required vertical position to match element exactly with the top widget part.

#func _ready() -> void:
  #%Body/TabContainer.resized.connect(_on_TabContainer_resized)
#
#func _draw() -> void:
  #reset_minimum_size()
#
#func reset_minimum_size() -> void:
  #size.y = int()
#
#func _on_TabContainer_resized() -> void:
  #%Body/TabContainer.size.y = int()
  #reset_minimum_size()
