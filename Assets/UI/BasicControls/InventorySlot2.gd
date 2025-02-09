@tool

extends TextureButton

class_name InventorySlot2

@export var resource_type: ItemData:
  get:
    return resource_type
  set(value):
    resource_type = value
    if self.is_node_ready() == false:
      await self.ready
    # set the tooltips to the correct values
    if resource_type:
      resource_image.texture = resource_type.icon
    else:
      resource_image.texture = null

@export var resource_amount: int = 0:
  get:
    return resource_amount
  set(value):
    resource_amount = min(limit, value)
    if self.is_node_ready() == false:
      await self.ready
    update_resource_amount_tooltips()

@export var limit: int = 30:
  get:
    return limit
  set(value):
    limit = value
    update_resource_amount_tooltips()

@onready var resource_image: TextureRect = self.get_node("HBoxContainer/ResourceImage")
@onready var amount_label: Label = self.get_node("HBoxContainer/VBoxContainer/AmountLabel")
@onready var amount_bar: TextureRect = self.get_node("HBoxContainer/VBoxContainer/AmountBar")
@onready var spacer: Control = self.get_node("HBoxContainer/VBoxContainer/Spacer")

func update_resource_amount_tooltips():
  amount_label.text = str(resource_amount)
  var resource_percentage = float(resource_amount) / float(limit)
  amount_bar.size_flags_stretch_ratio = resource_percentage
  spacer.size_flags_stretch_ratio = 1 - resource_percentage
