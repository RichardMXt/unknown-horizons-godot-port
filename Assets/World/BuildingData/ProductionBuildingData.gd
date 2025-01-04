extends BuildingData

class_name ProductionBuildingData

@export var max_storage_capacity: int = 10

@export_group("time")
@export var processing_time: int = 10
@export var load_or_unload_time: float = 2

@export_group("product")
@export var output_product: String
@export_subgroup("input product")
@export var input_product: String
@export var needs_intake_product: bool = true
