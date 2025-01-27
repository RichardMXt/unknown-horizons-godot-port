extends Node

class_name GameContextManager

## The current game context.
## When setted, calls exit_context on all contexts exept the context that is setted.
var current_context: BaseContext = null:
  get:
    return current_context
  set(value):
    current_context = value
    for child in self.get_children():
      if child is BaseContext and not child == value:
        child.is_active = false
      if child is BaseContext and child == value:
        child.is_active = true
