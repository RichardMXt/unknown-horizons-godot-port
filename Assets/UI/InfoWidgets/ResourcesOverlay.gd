extends Control
## Manages the resources overlay.
## If there are slots by defult, they to will be used.

class_name ResourceOverlay

@onready var resource_slots: HBoxContainer = self.get_node("HBoxContainer")
@onready var resource_selection: ResourceSelection = self.get_node("ResourceSelection")

const res_display_slot: PackedScene = preload("res://Assets/UI/BasicControls/ResourceDisplaySlot.tscn")

func _ready():
  # delete the default empty slots
  for slot: ResourceDisplaySlot in resource_slots.get_children():
    if slot.resource_type == null:
      slot.queue_free()
    else:
      slot.pressed.connect(pin_resource_to_slot.bind(slot))
  add_empty_resource_slot()

func add_empty_resource_slot() -> void:
  var empty_display_slot: ResourceDisplaySlot = res_display_slot.instantiate()
  resource_slots.add_child(empty_display_slot)
  empty_display_slot.pressed.connect(pin_resource_to_slot.bind(empty_display_slot))

func pin_resource_to_slot(slot: ResourceDisplaySlot) -> void:
  resource_selection.visible = true
  var resource_type = await resource_selection.resource_selected
  resource_selection.visible = false
  slot.resource_type = resource_type
  if resource_type:
    add_empty_resource_slot()
