extends BaseComponent
## The slot storage component is used in buildings to store resources
##
## The slot storage component is a components storing resources in different slots under a certain amount


class_name SlotStorageComponent

## The capacity of the storage slots.[br]
## [b]FORMAT[/b]: {(resource: [String]): max_amount}
@export var max_capacity: Dictionary

## The storage of the building.[br]
## [b]FORMAT[/b]: {(resource: [String]): amount}.[br]
## [b]Note[/b]: The [method SlotStorageComponent.set_storage_item_amount] function is to be used to set a key
var storage: Dictionary = {}:
  set(value): # for setting the the whole dictionary
    storage = value
    # check that the storage current key and value is in the right format
    for resource in value.keys():
      assert(resource is String and value[resource] is int, "The storage dictionary must be in the format (resource: amount)")
    storage_changed.emit()

## emited when the storage changes
signal storage_changed

func _ready():
  # check if the max_capacity and storage dictionary is in the right format and have all the nessesary keys in the storage
  for resource in max_capacity.keys():
    # check that the max_capacity current key and value is in the right format
    assert(resource is String and max_capacity[resource] is int, "The max capacity dictionary must be in the format (resource: amount)")
    if storage.has(resource) == false: # if the resource is not in the storage add it
      storage[resource] = 0
    else: # else, check that the storage current key and value is in the right format
      assert(resource is String and storage[resource] is int, "The storage dictionary must be in the format (resource: amount)")

## Used to set the storage amount of a specific resource.[br]
## The resource key will be created if it does not exist in the storage.[br]
## The resource key will be deleted if the amount is -1
func set_storage_item_amount(resource: String, new_amount: int):
  if new_amount == -1: # if the resource is null then delete the key
    storage.erase(resource)
  else:
    var max_amount = max_capacity.get(resource) # the max amount of the resource
    if max_amount != null: # if max_amount is not null, then set the resource amount to the min of the new_amount and max_amount
      storage[resource] = min(new_amount, max_amount)
    else: # else set the resource amount to 0
      storage[resource] = 0
      push_warning("The resource %s does not have a max capacity" % resource)
    storage_changed.emit()
