extends WorldThing2D

class_name BaseComponent

var paused: bool = false: set = pause_set

signal unpaused

func pause_set(value: bool) -> void:
  paused = value
  if self.paused == false:
    unpaused.emit()

## Default function to let the component know about neighboring components
func set_components(_new_components: Array[BaseComponent]) -> void:
  pass