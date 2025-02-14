@tool
extends Control
## If visible, will show the production chain and progress info.

class_name ProductionChain

@export var number_inputs: int = 1 : set = set_number_inputs

@export var input_one_type: ItemData : set = set_input_one_type
@export var input_two_type: ItemData : set = set_input_two_type
@export var input_three_type: ItemData : set = set_input_three_type
@export var output_type: ItemData : set = set_output_type

@export var input_one_value: int : set = set_input_one_value
@export var input_two_value: int : set = set_input_two_value
@export var input_three_value: int : set = set_input_three_value
@export var output_value: int : set = set_output_value

@export var input_one_storage_limit: int = 10 : set = set_input_one_storage_limit
@export var input_two_storage_limit: int = 10 : set = set_input_two_storage_limit
@export var input_three_storage_limit: int = 10 : set = set_input_three_storage_limit
@export var output_storage_limit: int = 10 : set = set_output_storage_limit

@onready var vbox_container := find_child("VBoxContainer")
@onready var top_section := find_child("TopSection")
@onready var middle_section := find_child("MiddleSection")
@onready var arrow_start := find_child("ArrowStart")
@onready var bottom_section := find_child("BottomSection")

@onready var input_one := find_child("InputOne") as InventorySlot
@onready var input_two := find_child("InputTwo") as InventorySlot
@onready var input_three := find_child("InputThree") as InventorySlot
@onready var output := find_child("Output") as InventorySlot

@onready var progress_bar: ColorRect = self.get_node("MarginContainer/VBoxContainer/MiddleSection/Control/ProgressBar/ProgressBar/ProgressBar")
@onready var progress_bar_spacer: Control = self.get_node("MarginContainer/VBoxContainer/MiddleSection/Control/ProgressBar/ProgressBar/Spacer")

func _ready():
  if Engine.is_editor_hint():
    self.set_process(false)
  else:
    self.set_process(true)

func _process(_delta):
  if self.owner.visible:
    var selected_objects = self.owner.selected_objects
    var progress: float = 0
    if len(selected_objects) == 1:
      var building = selected_objects[0]
      if building.production_timer != null:
        var production_time = building.building_data.processing_time
        progress = (production_time - building.production_timer.time_left) / production_time
    set_progress_bar(progress)

## Sets the progress bar to the given progress, 0 to 1 
func set_progress_bar(progress: float = 0):
  progress_bar.size_flags_stretch_ratio = progress
  progress_bar_spacer.size_flags_stretch_ratio = 1 - progress

func set_number_inputs(new_number_inputs: int) -> void:
  if not is_inside_tree():
    await self.ready

  number_inputs = clamp(new_number_inputs, 0, 3) as int

  match number_inputs:
    0: _set_inputs(false, false, false)
    1: _set_inputs(false, true, false)
    2: _set_inputs(true, false, true)
    3: _set_inputs(true, true, true)

func set_input_one_type(new_input_one_type: ItemData) -> void:
  input_one_type = new_input_one_type
  if not is_inside_tree():
    await self.ready

  input_one.resource_type = input_one_type

func set_input_two_type(new_input_two_type: ItemData) -> void:
  input_two_type = new_input_two_type
  if not is_inside_tree():
    await self.ready

  input_two.resource_type = input_two_type


func set_input_three_type(new_input_three_type: ItemData) -> void:
  input_three_type = new_input_three_type
  if not is_inside_tree():
    await self.ready

  input_three.resource_type = input_three_type

func set_output_type(new_output_type: ItemData) -> void:
  output_type = new_output_type
  if not is_inside_tree():
    await self.ready

  output.resource_type = output_type

func set_input_one_value(new_input_one_value: int) -> void:
  input_one_value = new_input_one_value
  if not is_inside_tree():
    await self.ready

  input_one.resource_amount = input_one_value
  print(input_one.resource_amount)
  notify_property_list_changed()

func set_input_two_value(new_input_two_value: int) -> void:
  input_two_value = new_input_two_value
  if not is_inside_tree():
    await self.ready

  input_two.resource_amount = input_two_value
  notify_property_list_changed()

func set_input_three_value(new_input_three_value: int) -> void:
  input_three_value = new_input_three_value
  if not is_inside_tree():
    await self.ready

  input_three.resource_amount = input_three_value
  notify_property_list_changed()

func set_output_value(new_output_value: int) -> void:
  if not is_inside_tree():
    await self.ready

  output.resource_amount = new_output_value
  output_value = output.resource_amount

  notify_property_list_changed()

func set_input_one_storage_limit(new_input_one_storage_limit: int) -> void:
  input_one_storage_limit = new_input_one_storage_limit
  if not is_inside_tree():
    await self.ready

  input_one.storage_limit = input_one_storage_limit

func set_input_two_storage_limit(new_input_two_storage_limit: int) -> void:
  input_two_storage_limit = new_input_two_storage_limit
  if not is_inside_tree():
    await self.ready

  input_two.storage_limit = input_two_storage_limit

func set_input_three_storage_limit(new_input_three_storage_limit: int) -> void:
  input_three_storage_limit = new_input_three_storage_limit
  if not is_inside_tree():
    await self.ready

  input_three.storage_limit = input_three_storage_limit

func set_output_storage_limit(new_output_storage_limit: int) -> void:
  output_storage_limit = new_output_storage_limit
  if not is_inside_tree():
    await self.ready

  output.storage_limit = output_storage_limit

func _set_input_one(enabled: bool) -> void:
  top_section.visible = enabled

func _set_input_two(enabled: bool) -> void:
  input_two.modulate.a = 1 if enabled else 0
  arrow_start.visible = enabled

func _set_input_three(enabled: bool) -> void:
  bottom_section.visible = enabled

func _set_inputs(input_one: bool, input_two: bool, input_three: bool) -> void:
  _set_input_one(input_one)
  _set_input_two(input_two)
  _set_input_three(input_three)

  queue_redraw()

func _notification(what: int) -> void:
  match what:
    NOTIFICATION_DRAW:
      if not is_inside_tree():
        await self.ready

      # Reset to minimum size first.
      custom_minimum_size = middle_section.size
      vbox_container.size = custom_minimum_size

      # Then expand to necessary size.
      custom_minimum_size = vbox_container.size

      # Control node cannot expand automatically to min size, so force it.
      size = custom_minimum_size

      notify_property_list_changed()
