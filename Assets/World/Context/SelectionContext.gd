extends BaseContext
## Is responsible for doing selection

class_name SelectionContext

@onready var built_tilemap: BuiltTileMap = %BuiltTileMap
@onready var selection_box: SelectionBox = self.get_node("CanvasLayer/SelectionBox")

var selection_rect: Rect2 = Rect2()
var selected_objects: Array[Selectable] = []

func _unhandled_input(event):
  if event.is_action_released("exit"):
    # if there are any selected objects, deselect them
    if selected_objects:
      for object: Selectable in selected_objects:
        object.is_selected = false
      selected_objects = []
    # in the future, if seleted_objects is empty, exit to main menu.
  
  if self.is_active:
    if event is InputEventMouseButton:
      if event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed == true:
          # print(built_tilemap.get_global_mouse_position())
          selection_rect.position = built_tilemap.get_global_mouse_position()
          selection_box.sel_pos_start = get_viewport().get_mouse_position()
          selection_box.visible = true
        else:
          # print(built_tilemap.get_global_mouse_position())
          selection_rect.end = built_tilemap.get_global_mouse_position()
          selection_rect = selection_rect.abs()
          # print(selection_rect.position, selection_rect.size)
          assert(selection_rect.size.x >= 0 and selection_rect.size.y >= 0)
          selection_box.visible = false
          select_objects()

func select_objects():
  # Deselect all objects that are currently selected
  for object: Selectable in selected_objects:
    object.is_selected = false
  selected_objects = []
  # Select all objects that are in the selection rect
  var selectable_objects = get_tree().get_nodes_in_group("Selectable")
  for selectable_object: Selectable in selectable_objects:
    if selectable_object.is_in_rect(selection_rect):
      selected_objects.append(selectable_object)
      selectable_object.is_selected = true
