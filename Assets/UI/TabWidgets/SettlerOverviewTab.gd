extends VBoxContainer

@onready var caption_block:CaptionBlock = $CaptionBlock
@onready var taxes_control: TaxesControl = %TaxesControl

var selected_node: WorldThing2D = null:
  set(value):
    selected_node = value
    on_new_selected_node(value)

func on_new_selected_node(node: WorldThing2D) -> void:
  var building_selected: Building2D = node as Building2D
  if building_selected != null:
    self.taxes_control.tax_rate = GameStats.treasury.tax_rate_per_tier.get(building_selected.current_tier_val, 1.0)
    self.taxes_control.tax_rate_changed.connect(func (tax_rate: float): GameStats.treasury.tax_rate_per_tier[building_selected.current_tier_val] = tax_rate)  

  for child in self.get_children():
    if "selected_node" in child:
      child.selected_node = node
