@tool
extends VBoxContainer

@onready var overlays_tab_container: TabContainer = %Overlays
# @onready var finance_overlay: MarginContainer = %FinanceOverlay
@onready var building_cost_label: LabelEx = %BuildingCostLabel

@onready var gold_label: LabelEx = %GoldLabel
@onready var expenses_balance_info_item: BalanceInfoButton = %ExpensesBalanceInfoItem
@onready var revenue_balance_info_item: BalanceInfoButton = %RevenueBalanceInfoItem
@onready var buy_balance_info_item: BalanceInfoButton = %BuyBalanceInfoItem
@onready var sell_balance_info_item: BalanceInfoButton = %SellBalanceInfoItem
@onready var total_balance_per_second: BalanceInfoButton = %Balance
@onready var details = %ShowDetails

@export var show_details: bool:
  set(value):
    if not is_inside_tree():
      await self.ready

    show_details = value
    details.visible = show_details


func _ready() -> void:
  show_details = details.visible

func _input(event: InputEvent) -> void:
  var building: StringName = &""
  if event.is_action_pressed("toggle_build_road"):
    building = &"Trail" # trail toggled, set name as trail
  if event.is_action_pressed("toggle_build_building"):
    var building_str: StringName = event.get_meta("button_name").trim_prefix("Build").trim_suffix("Button")
    building = BuildingConfig.Buildings.get(building_str.to_snake_case().to_upper(), &"")
  if building != &"": # show the building gold cost label
    self.overlays_tab_container.current_tab = self.overlays_tab_container.get_tab_idx_from_control(self.building_cost_label)
    var gold_cost: int = BuildingConfig.building_to_cost.get(building, {}).get(ResourceConfig.Resources.GOLD, 0)
    self.building_cost_label.text = "-%s" % gold_cost

  if event.is_action_pressed("cancel_build"):
    self.overlays_tab_container.current_tab = 0 # set default tab

func _on_TextureButton_pressed() -> void:
  self.show_details = !show_details
  self.refresh()

func refresh():
  var treasury = GameStats.treasury
  self.gold_label.text = str(GameStats.game_stats_resource.resources.get(ResourceConfig.Resources.GOLD))
  self.expenses_balance_info_item.balance_value = -treasury.total_cost_per_second
  self.revenue_balance_info_item.balance_value = treasury.total_revenue_per_second
  self.total_balance_per_second.balance_value = treasury.total_balance_per_second
