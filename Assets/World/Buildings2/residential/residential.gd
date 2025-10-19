extends Building2D

class_name Residential

@export var stable_inhabitants_range: Vector2 = Vector2(30, 70)
@export var stable_upgrade_range: Vector2 = Vector2(10, 80)
@export var max_inhabitants_for_tiers: Dictionary[StringName, int] = {}

var inhabitants: int = 1:
  set(value):
    inhabitants = clampi(value, 1, self.max_inhabitants_for_tiers.get(self.current_tier, 10))

var next_available_upgrade_time: float = Time.get_unix_time_from_system() + 5.0

func _ready():
  for storage: StorageComponent in self.get_all_nodes_of_type(StorageComponent):
    storage.storage_changed.connect(self.update_tier)
  for production_line: ProductionLineComponent in self.get_all_nodes_of_type(ProductionLineComponent):
    if ResourceConfig.Resources.HAPPINESS in production_line.produces.keys():
      production_line.action_state_changed.connect(self.update_tier.unbind(1))
  super()

func update_tier() -> void:
  var unix_time: float = Time.get_unix_time_from_system()
  if unix_time < next_available_upgrade_time:
    return # avoid upgrading instantly
  var happiness_produced := self.get_happiness_produced_per_minute()
  # -1 if decreasing, 0 if stable, 1 if increasing
  var inhabitants_change := signi(happiness_produced - clamp(happiness_produced, self.stable_inhabitants_range.x, self.stable_inhabitants_range.y))
  # -1 if downgrading, 0 if stable, 1 if upgrading
  var tier_change := signi(happiness_produced - clamp(happiness_produced, self.stable_upgrade_range.x, self.stable_upgrade_range.y))
  self.inhabitants += inhabitants_change

  var enum_tier: WorldTiers.TierEnum = WorldTiers.TierEnum.get(self.current_tier, WorldTiers.TierEnum.SAILORS)
  var new_enum_tier := clampi(enum_tier + tier_change, WorldTiers.TierEnum.SAILORS, WorldTiers.TierEnum.MERCHANTS)
  var new_tier: StringName = WorldTiers.TierEnum.find_key(new_enum_tier)
  self.current_tier = new_tier
  next_available_upgrade_time = unix_time + 5.0
  # continue upgrading while possible
  if new_tier != self.current_tier:
    await self.sleep(5.1) # 5.1 secondes before checking for upgrade again(wait for upgrde to be allowed)
    self.update_tier()


func get_happiness_produced_per_minute() -> float:
  var happiness_producing_speed_per_second: float = 0.0
  for production_line: ProductionLineComponent in self.get_all_nodes_of_type(ProductionLineComponent):
    if production_line.production_stage != ProductionLineComponent.ProductionStages.PRODUCING or not ResourceConfig.Resources.HAPPINESS in production_line.produces.keys():
      continue # not producing happiness
    happiness_producing_speed_per_second += production_line.produces[ResourceConfig.Resources.HAPPINESS] / production_line.production_time
  return happiness_producing_speed_per_second * 60
