extends Building2D

class_name Residential

## The range within which the inhabitants of this building are stable(not increasing or decreasing)
@export var stable_inhabitants_range: Vector2 = Vector2(30, 70)
## The range within which the tier of this building is stable(not increasing or decreasing)
@export var stable_tier_range: Vector2 = Vector2(10, 80)
## The maximum number of inhabitants for each tier, ten by default
@export var max_inhabitants_for_tiers: Dictionary[StringName, int] = {}

@export var happiness_usage_per_inhabitant: int = 20
@export var happiness_usage_per_tier: int = 40

## emitted when the number of inhabitants of this building changes
signal inhabitants_changed(inhabitants: int)

var inhabitants: int = 1:
  set(value):
    var previous_inhabitants := self.inhabitants
    inhabitants = clampi(value, 1, self.max_inhabitants_for_tiers.get(self.current_tier, 10))

    self.spend_happiness((inhabitants - previous_inhabitants) * self.happiness_usage_per_inhabitant)
    
    self.inhabitants_changed.emit(self.inhabitants)

var next_available_upgrade_time: float = 0

func set_tier(new_tier: StringName) -> void:
  var previous_enum_tier: WorldTiers.TierEnum = WorldTiers.TierEnum.get(self.current_tier, WorldTiers.TierEnum.SAILORS)
  current_tier = new_tier
  var current_enum_tier: WorldTiers.TierEnum = WorldTiers.TierEnum.get(self.current_tier, WorldTiers.TierEnum.SAILORS)
  # notify children
  for node: Node in self.get_children():
    if "current_tier" in node:
      if node.current_tier is StringName: # if uses StringName
        node.current_tier = self.current_tier
      elif node.current_tier is WorldTiers.TierEnum: # if uses enum
        node.current_tier = current_enum_tier
  
  # spend/gain happiness from upgarde/downgrade
  self.spend_happiness((current_enum_tier - previous_enum_tier) * self.happiness_usage_per_tier)
  # update world tier
  var world_enum_tier: WorldTiers.TierEnum = WorldTiers.TierEnum.get(GameStats.game_stats_resource.world_tier, WorldTiers.TierEnum.SAILORS)
  if world_enum_tier < current_enum_tier:
    GameStats.game_stats_resource.world_tier = self.current_tier

func connect_set_tier() -> void:
  # listen to storage changes and do not listen to world tier
  for storage: StorageComponent in self.get_all_nodes_of_type(StorageComponent):
    storage.storage_changed.connect(self.update_tier.unbind(1))

func update_tier() -> void:
  var unix_time: float = Time.get_unix_time_from_system()
  if unix_time <= self.next_available_upgrade_time:
    return # avoid upgrading instantly

  # calculate happiness
  var happiness := 0
  var storages: Array = self.get_all_nodes_of_type(StorageComponent)
  for storage: StorageComponent in storages:
    happiness += storage.get_storage_item_amount(ResourceConfig.Resources.HAPPINESS)
  # print("    inhabitants: %s |     tier: %s |     happiness: %s" % [self.inhabitants, self.current_tier, happiness])

  # set inhabitants
  # -1 if decreasing, 0 if stable, 1 if increasing
  var inhabitants_change := signi(happiness - clamp(happiness, self.stable_inhabitants_range.x, self.stable_inhabitants_range.y))
  var last_inhabitants := self.inhabitants
  self.inhabitants += inhabitants_change
  if last_inhabitants != self.inhabitants:
    self.next_available_upgrade_time = unix_time + 5.0
    return # increase inhabitants first
  
  # set tier
  # -1 if downgrading, 0 if stable, 1 if upgrading
  var last_tier := self.current_tier
  var tier_change := signi(happiness - clamp(happiness, self.stable_tier_range.x, self.stable_tier_range.y))
  var enum_tier: WorldTiers.TierEnum = WorldTiers.TierEnum.get(self.current_tier, WorldTiers.TierEnum.SAILORS)
  var new_enum_tier := clampi(enum_tier + tier_change, WorldTiers.TierEnum.SAILORS, WorldTiers.TierEnum.MERCHANTS)
  var new_tier: StringName = WorldTiers.TierEnum.find_key(new_enum_tier)
  self.current_tier = new_tier
  if last_tier != self.current_tier:
    self.next_available_upgrade_time = unix_time + 5.0
  
  # # log default
  # print("New inhabitants: %s | New tier: %s | New happiness: %s" % [self.inhabitants, self.current_tier, 
  # self.get_first_node_of_type(StorageComponent).get_storage_item_amount(ResourceConfig.Resources.HAPPINESS)])

## goes across all storages trying to spend the given amount of happiness
func spend_happiness(happiness_to_spend: int):
  var storages := self.get_all_nodes_of_type(StorageComponent)
  var i := 0
  while abs(happiness_to_spend) > 0:
    if i >= len(storages):
      push_error("trying to increase inhabitants but not enough happiness in storages")
      break
    var storage: StorageComponent = storages[i]
    var happiness_in_storage: int = storage.get_storage_item_amount(ResourceConfig.Resources.HAPPINESS)
    var happiness_to_take_or_give := mini(happiness_to_spend, happiness_in_storage)
    storage.set_storage_item_amount(ResourceConfig.Resources.HAPPINESS, happiness_in_storage - happiness_to_take_or_give)
    happiness_to_spend -= happiness_to_take_or_give
