extends Resource
class_name ToolDefinition

@export var tool_id: String = ""
@export var display_name: String = ""
# "socket_set", "drain_pan", "floor_jack", "jack_stands", "screwdriver_set",
# "spring_compressor", "torque_wrench", "impact_wrench", "transmission_jack"
@export var tool_type: String = ""
@export var cost: float = 0.0
@export var is_starting_tool: bool = false
