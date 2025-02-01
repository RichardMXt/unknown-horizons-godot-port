extends Node
##

class_name Selectable

## The sprite to be highlighted when selected.
## If null, will use the first found animated sprite sibling.
@export var sprite: Node2D
## The shader to be used to highlight the sprite.
@export var shader: ShaderMaterial = preload("res://Assets/World/Behavior/Selectable/SelectableDefultShader.tres")

@onready var parent: Node2D = self.get_parent()

## The shader`s defult width
var shader_width: float = shader.get_shader_parameter("width")
## Whether the object is currently selected
var is_selected: bool = false:
  get:
    return is_selected
  set(value):
    is_selected = value
    # change the shader transparency to the correct one.
    if sprite:
      if is_selected:
        sprite.material.set_shader_parameter("width", shader_width)
      else:
        sprite.material.set_shader_parameter("width", 0)

func _ready():
  if not sprite or not (sprite is AnimatedSprite2D or sprite is Sprite2D):
    for child in self.get_parent().get_children():
      if child is AnimatedSprite2D or child is Sprite2D:
        sprite = child
  if not sprite:
    push_warning("There was no sprite found to highlight in %s." % self.get_parent().name)
  else:
    sprite.material = shader.duplicate(true)
    sprite.material.set_shader_parameter("width", 0)

func _unhandled_input(event):
  if is_selected:
    parent.handle_context_input(event)

func is_in_rect(rect: Rect2) -> bool:
  if sprite:
    var sprite_size: Vector2
    if sprite is AnimatedSprite2D:
      var sprite_frame: Texture2D = sprite.get_sprite_frames().get_frame_texture(sprite.animation, sprite.frame)
      sprite_size = sprite_frame.get_size() * sprite.scale
    else:
      if sprite.region_enabled:
        sprite_size = sprite.region_rect.size * sprite.scale
      else:
        sprite_size = sprite.texture.get_size() * sprite.scale
    var sprite_rect: Rect2 = Rect2(sprite.global_position - sprite_size/2, sprite_size).abs()
    var does_intersect: bool = rect.intersects(sprite_rect) and parent.visible
    return does_intersect
  else:
    return false
