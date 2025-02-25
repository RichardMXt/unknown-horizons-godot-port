@tool

extends BaseComponent
## The action set component is used in buildings to determine the image and more.
## Important: The animation will be determined by "{tier_prefix}{base_prefix}{Angle}", with the tier_prefix being a first letter capitalized tier name.

class_name ActionSet

## The sprite frames for the image of the building
@export var sprite_frames: SpriteFrames = null:
  set(value):
    sprite_frames = value
    if animated_sprite == null:
      return
    if sprite_frames:
      animated_sprite.sprite_frames = sprite_frames
    else:
      push_warning("No sprite frames assigned")
    update_animtion()

@export_group("Tiers")
# The tiers at which the animation will change
@export_subgroup("ShouldChangeSpriteAtTier", "change_sprite_at_tier_")
@export var change_sprite_at_tier_sailors: bool = false:
  set(value):
    change_sprite_at_tier_sailors = value
    update_animtion()

@export var change_sprite_at_tier_pioneers: bool = false:
  set(value):
    change_sprite_at_tier_pioneers = value
    update_animtion()

@export var change_sprite_at_tier_settlers: bool = false:
  set(value):
    change_sprite_at_tier_settlers = value
    update_animtion()

@export var change_sprite_at_tier_citizens: bool = false:
  set(value):
    change_sprite_at_tier_citizens = value
    update_animtion()

@export var change_sprite_at_tier_merchants: bool = false:
  set(value):
    change_sprite_at_tier_merchants = value
    update_animtion()

## The current tier
@export var tier: ActionSetEnum.tiers = ActionSetEnum.tiers.SAILORS:
  set(value):
    tier = value
    update_animtion()

## The rotation of the building, used to determine the animation
@export var rotation_to_nearest_45_deg: int = 45:
  set(value):
    rotation_to_nearest_45_deg = int(value / 45.0 + 0.5) * 45
    update_animtion()

@onready var animated_sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

const empty_animation: String = "Empty"

func _ready():
  if animated_sprite:
    animated_sprite.sprite_frames = sprite_frames
  update_animtion()

func update_animtion() -> void:
  # if the sprite frames or the animated sprite is null then return because there is nothing to update
  if animated_sprite == null or sprite_frames == null:
    return
  
  # get the last tier name at which the animation should have changed
  var change_tiers: Array[bool] = [
    change_sprite_at_tier_sailors,
    change_sprite_at_tier_pioneers,
    change_sprite_at_tier_settlers,
    change_sprite_at_tier_citizens,
    change_sprite_at_tier_merchants
  ] # declare an array in which the should_change_sprite vars are in order
  
  var last_sprite_change_tier_name: String = "" # declare the last tier at which the sprite should have changed
  var keys: Array = ActionSetEnum.tiers.keys() # get the keys
  for i in range(len(keys)): # iterate over all the keys
    var should_change_sprite: bool = change_tiers[i] # should change sprite at tier at the current index
    if should_change_sprite == true: # if the should_change_sprite var at the current index is true then set the last_change_sprite_tier_name to i
      last_sprite_change_tier_name = keys[i]
    var tier_at_cur_index: ActionSetEnum.tiers = ActionSetEnum.tiers[keys[i]] # the tier corresponding to the current index
    if tier_at_cur_index == tier: # tier_at_cur_index is equal to the actual tier, then break because we have checked all the previous tiers
      break
  
  if last_sprite_change_tier_name == "":
    animated_sprite.play(empty_animation)
    return
  else:
    var tier_state: String = last_sprite_change_tier_name.to_lower()
    var work_state: String = "idle"
    # TODO: get the work state from a production line when defined ->
    # if production_line != null and production_line.should_produce:
    #   work_state = "work"
    var animation_name: String = tier_state + "_" + work_state + "_" + str(rotation_to_nearest_45_deg)
    if animation_name in sprite_frames.get_animation_names():
      animated_sprite.play(animation_name)
    else:
      push_warning("Animation not found: " + animation_name)
      animated_sprite.play(empty_animation)
