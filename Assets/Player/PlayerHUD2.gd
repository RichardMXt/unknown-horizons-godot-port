extends Control


# # Called when the node enters the scene tree for the first time.
# func _ready() -> void:
#   pass # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#   pass

func get_tab_index(tab_container: TabContainer, target_control: Control) -> int:
  var tab_index := -1
  for i in range(tab_container.get_tab_count()):
    if tab_container.get_tab_control(i) == target_control:
      tab_index = i
      break
  return tab_index

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("toggle_building_menu"):
    var tab_container: TabContainer = %BuildMenuByCategoryTabWidget.get_parent();
    var tab_index := get_tab_index(tab_container, %BuildMenuByCategoryTabWidget)
    if tab_container.current_tab == tab_index:
      tab_container.current_tab = 0 # switch off the tabs, by switching to the first tab
    else:
      tab_container.current_tab = tab_index

  if event.is_action_pressed("toggle_diplomacy_menu"):
    push_warning("Diplomacy menu is not implemented yet.")
    var tab_container: TabContainer = %BuildMenuByCategoryTabWidget.get_parent();
    # var tab_index := get_tab_index(tab_container, %BuildMenuByCategoryTabWidget)
    var tab_index := 0
    if tab_container.current_tab == tab_index:
      tab_container.current_tab = 0 # switch off the tabs, by switching to the first tab
    else:
      tab_container.current_tab = tab_index
