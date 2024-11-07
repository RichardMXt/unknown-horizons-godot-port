extends AnimatableBody2D

class_name Person

@export var max_carry_limit: int = 10
@export var speed_tile_per_sec: float = 1

#@onready var tile_map: TileMapLayer = get_node("../Builded")
@onready var MoveTimer: Timer = get_node("MoveTimer")

var path: Array = []
var path_left: Array = []

var objects_carring: Dictionary = {"there": ["", 0], "here": null}
var object_carring: String
var count_of_objects: int
var is_moving: bool



#func _unhandled_input(event):
  #if event is InputEventMouseButton:
    #if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
      #move(self.get_global_mouse_position())



func move():
  object_carring = objects_carring.get("there")[0]
  count_of_objects = objects_carring.get("there")[1]
  if object_carring == "" or count_of_objects <= 0:
    return
  if len(path) > 0 and not is_moving and max_carry_limit >= count_of_objects:
    is_moving = true
    self.visible = true
    path_left = path.duplicate()
    _on_move_timer_timeout()
    MoveTimer.start(speed_tile_per_sec)



func _on_move_timer_timeout():
  var tile_layer_pos = path_left.pop_front()
  var building_pos = tile_layer_pos - self.get_parent().position
  self.position = building_pos

  if len(path_left) <= 0:
    var building = BuildingManager.building_pos_to_building.get(tile_layer_pos)
    
    if building != null:
      
      if building.game_name == "WareHouse":
        
        path_left = path.duplicate()
        path_left.reverse()
        
        building.unload_person(count_of_objects, object_carring)
        count_of_objects = 0

        count_of_objects = building.load_person(count_of_objects, object_carring)
        if objects_carring.get("here") != null and count_of_objects != null:
          object_carring = objects_carring.get("here")[0]


      if building.game_name == self.get_parent().game_name:
        self.visible = false
        is_moving = false
        path_left = path.duplicate()
        MoveTimer.stop()
        building.number_of_intake_products += count_of_objects
        count_of_objects = 0
