extends VBoxContainer

@onready var caption_block:CaptionBlock = $CaptionBlock
@onready var taxes_control: TaxesControl = %TaxesControl
@onready var happiness_slider: HSlider = %HappinessSlider
@onready var residents_count_label: Label = %ResidentsCountLabel

var selected_node: WorldThing2D = null:
  set(value):
    selected_node = value
    on_new_selected_node(value)

func on_new_selected_node(node: WorldThing2D) -> void:
  var residential: Residential = node as Residential
  if residential != null:
    self.taxes_control.tax_rate = GameStats.treasury.tax_rate_per_tier.get(residential.current_tier_val, 1.0)
    self.taxes_control.tax_rate_changed.connect(func (tax_rate: float): GameStats.treasury.tax_rate_per_tier[residential.current_tier_val] = tax_rate)

    self.happiness_slider.value = residential.get_happiness()

    self.residents_count_label.text = str(residential.residence) + " / " + str(residential.max_residents_for_current_tier)

  for child in self.get_children():
    if "selected_node" in child:
      child.selected_node = node
