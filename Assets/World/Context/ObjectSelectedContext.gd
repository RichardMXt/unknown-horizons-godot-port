extends BaseContext
## Is responsible for operating with selected objects

class_name ObjectSelectedContext

@export var empty_tab_widget_name: String = "EmptyPanelContainer"

## are all selected objects of the same type
var are_selected_objects_same_type: bool = true

var selected_objects: Array[Selectable] = []:
  get:
    return selected_objects
  set(value):
    var last_selected_objects: Array[Selectable] = selected_objects
    selected_objects = value
    # deselect all selected objects
    for object: Selectable in last_selected_objects:
      object.is_selected = false
    # check if there are some selected objects
    if not selected_objects:
      are_selected_objects_same_type = false
      %GameContextManager.current_context = null
    else:
      # select all objects to select and check if all are of the same type
      var one_of_selected_objects_types: String = selected_objects[0].get_parent().get_class()
      are_selected_objects_same_type = true
      for object: Selectable in selected_objects:
        are_selected_objects_same_type = are_selected_objects_same_type and object.get_parent().is_class(one_of_selected_objects_types)
        object.is_selected = true
    set_tab_widget()

func _unhandled_input(event):
  if self.is_active:
    if event.is_action_released("exit") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
      for object: Selectable in selected_objects:
        object.is_selected = false
      selected_objects = []
      %GameContextManager.current_context = null

func set_tab_widget():
  var tab_widget_name: String = ""
  var event = InputEventAction.new()
  if are_selected_objects_same_type:
    # get the info tab widget
    var object = selected_objects[0].get_parent()
    var info_tab_widget: Resource
    if object is Building2D:
      info_tab_widget = object.building_data.info_tab_widget
    if object is Unit2D:
      info_tab_widget = object.unit_data.info_tab_widget
    # get the tab widget name
    if info_tab_widget:
      tab_widget_name = info_tab_widget.resource_path.get_file().get_basename()
    else:
      tab_widget_name = empty_tab_widget_name

  else:
    tab_widget_name = empty_tab_widget_name
  
  event.action = "toggle_building_info_menu"
  event.pressed = true
  event.set_meta("tab_widget_name", tab_widget_name)
  Input.parse_input_event(event)

