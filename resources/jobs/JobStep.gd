extends Resource
class_name JobStep

@export var step_id: String = ""
@export var description: String = ""
# "drain_fluid", "remove_part", "install_part", "fill_fluid", "lift_car", "lower_car"
@export var action_type: String = ""
@export var target_id: String = ""
@export var required_tool_id: String = ""
@export var hint: String = ""
