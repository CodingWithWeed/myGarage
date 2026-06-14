extends Resource
class_name JobDefinition

@export var job_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var tier: int = 1
@export var base_payout: float = 0.0
@export var required_tool_ids: Array[String] = []
@export var steps: Array[Resource] = []
@export var vehicle_type: String = "sedan"  # "sedan", "hatchback", "van"
@export var estimated_hours: float = 1.0
