extends VBoxContainer

@onready var caption_block := $CaptionBlock as CaptionBlock

var selected_node: WorldThing2D = null:
  set(value):
    selected_node = value
    on_new_selected_node(value)

func on_new_selected_node(node: WorldThing2D) -> void:
  var building_selected: Building2D = node as Building2D
  if building_selected != null:
    self.caption_block.caption_text = building_selected.game_name
