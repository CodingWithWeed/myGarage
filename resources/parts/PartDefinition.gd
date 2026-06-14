extends Resource
class_name PartDefinition

@export var id: String = ""
@export var display_name: String = ""
@export var category: String = ""
@export var source: String = "store"  # "store" or "junkyard"
@export var base_cost: float = 0.0
@export var weight: float = 1.0
@export var install_slot_id: String = ""
@export var dependency_slot_ids: Array[String] = []
@export var is_restorable: bool = false
@export var restoration_type: String = ""  # "machine_shop", "workbench", or ""
