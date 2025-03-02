extends Object
## The resource config is used to store all the item data, maping, and other item information

class_name ResourceConfig

const item_data_folder_path: String = "res://Assets/World/Data/ItemData/"

## The map of item names to items.[br]
## [b]Format[/b]: {item_name([String]): item_data([ItemData])}
static var item_map: Dictionary = {
  "Flour": preload(item_data_folder_path + "Flour.tres"),
  "Food": preload(item_data_folder_path + "Food.tres"),
  "Timber": preload(item_data_folder_path + "Timber.tres"),
  "Wood": preload(item_data_folder_path + "Wood.tres"),
}

## @deprecated: Use strings for keys instead, until typed dictionaries are supported
enum resources {
  FLOUR,
  FOOD,
  TIMBER,
  WOOD,
}
