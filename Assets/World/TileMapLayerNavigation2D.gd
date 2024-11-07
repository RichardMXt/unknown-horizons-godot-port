extends TileMapLayer

var astar_grid = RoadPathFindingManagment2D.new(self)



func get_path_to_dest(start: Vector2, final_dest: Vector2):
  return astar_grid.get_path_to_dest(start, final_dest)
  


func _unhandled_input(event):
  if event is InputEventMouseButton:
    if event.pressed == true:
      if event.button_index == MOUSE_BUTTON_LEFT:
        
        var grid_building_pos = self.local_to_map(self.get_global_mouse_position() - self.position)
        var world_building_pos = self.map_to_local(grid_building_pos)
        var building_to_build = BuildingManager.get_building_to_build(world_building_pos)
        if building_to_build != null:
          #if self.get_cell_source_id()
          var tile_id = get_id(building_to_build)
          #print(self.get_cell_source_id(grid_building_pos))
          #print(self.get_cell_atlas_coords(grid_building_pos))
          if tile_id != null:
            build_building(tile_id)

      if event.button_index == MOUSE_BUTTON_RIGHT:
        BuildingManager.building_to_build == null
        return



func get_id(building_to_build):
# note: to be replaced
  var building_id
  if building_to_build == "Farm":
    building_id = 1
  if building_to_build == "WareHouse":
    building_id = 2
  
  return building_id



func build_building(id):

  if id != null:
    
    var grid_building_pos = self.local_to_map(self.get_global_mouse_position() - self.position)
    
    astar_grid.set_point_solid(grid_building_pos, false)
    #building = building.instantiate()
    #building.position = world_building_pos
    #self.add_child(building)
    self.set_cell(grid_building_pos, 0, Vector2i(0, 0), id)
    BuildingManager.register_building(self.get_child(self.get_child_count()))
