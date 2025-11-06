@tool
extends VBoxContainer

@onready var tab_container: TabContainer = $Container/VBoxContainer/TabContainer
@onready var finance_overlay: MarginContainer = %FinanceOverlay
@onready var building_cost_overlay: HBoxContainer = %BuildingCostOverlay

@onready var gold_label: LabelEx = $TextureButton/GoldLabel
@onready var expenses_balance_info_item: BalanceInfoButton = %ExpensesBalanceInfoItem
@onready var revenue_balance_info_item: BalanceInfoButton = %RevenueBalanceInfoItem
@onready var buy_balance_info_item: BalanceInfoButton = %BuyBalanceInfoItem
@onready var sell_balance_info_item: BalanceInfoButton = %SellBalanceInfoItem
@onready var total_balance_per_second: BalanceInfoButton = %Balance

@onready var building_cost_label: LabelEx = %BuildingCostLabel

@export var show_details: bool:
  set(value):
    if not is_inside_tree():
      await self.ready

    show_details = value
    details.visible = show_details

@onready var details = %ShowDetails

func _ready() -> void:
  show_details = details.visible

func _input(event: InputEvent) -> void:
  var building_str: StringName = &""
  if event.is_action_pressed("toggle_build_road"):
    building_str = &"Trail"
  if event.is_action_pressed("toggle_build_building"):
    var building_name: StringName = event.get_meta("button_name").trim_prefix("Build").trim_suffix("Button")
    building_str = BuildingConfig.Buildings.get(building_name.to_snake_case().to_upper(), &"")
  if building_str != &"":
    self.tab_container.current_tab = self.tab_container.get_tab_idx_from_control(building_cost_overlay)
    var gold_cost: int = BuildingConfig.building_to_cost.get(building_str, {}).get(ResourceConfig.Resources.GOLD, 0)
    building_cost_label.text = "-%s" % gold_cost

  if event.is_action_pressed("cancel_build"):
    self.tab_container.current_tab = 0 # set default tab

func _on_TextureButton_pressed() -> void:
  self.show_details = !show_details
  self.refresh()

func refresh():
  var treasury = GameStats.treasury
  self.gold_label.text = str(GameStats.game_stats_resource.resources.get(ResourceConfig.Resources.GOLD))
  self.expenses_balance_info_item.balance_value = -treasury.total_cost_per_second
  self.revenue_balance_info_item.balance_value = treasury.total_revenue_per_second
  self.total_balance_per_second.balance_value = treasury.total_balance_per_second
