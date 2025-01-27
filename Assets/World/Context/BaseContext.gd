extends Node

class_name BaseContext

## Defines if the context is active.
## When value changed, calls the "enter/exit context" methods.
## Note: the is_active property is set after notifying.
var is_active: bool = false:
  get:
    return is_active
  set(value):
    if value != is_active: # check if the context truely changes state
      if value:
        context_entered()
      else:
        context_exited()
    is_active = value

## Called when the context enters the active state.
## Override this method to do something at the activation of the context.
func context_entered() -> void:
  print(self.name + " entered")

## Called when the context exits the active state.
## Override this method to do something at the deactivation of the context.
func context_exited() -> void:
  print(self.name + " exited")
