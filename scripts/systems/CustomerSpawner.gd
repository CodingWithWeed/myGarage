extends Node
class_name CustomerSpawner

@export var min_wait_hours: float = 1.0
@export var max_wait_hours: float = 4.0

var _hours_since_last_customer: float = 0.0
var _next_threshold: float = 2.0
var _customer_active: bool = false

# Lightweight job pool — full JobDefinition resources added later in Phase 3
var _job_pool: Array[Dictionary] = [
	{
		"job_id": "oil_change_001",
		"display_name": "Oil & Filter Change",
		"description": "Customer needs an oil and filter change.",
		"tier": 1,
		"base_payout": 75.0,
		"vehicle_type": "sedan",
		"estimated_hours": 0.5,
		"required_tool_ids": ["socket_set", "oil_drain_pan"],
		"steps_total": 4,
	},
	{
		"job_id": "brake_pads_front_001",
		"display_name": "Front Brake Pad Replacement",
		"description": "Front brake pads are worn, customer wants both sides replaced.",
		"tier": 2,
		"base_payout": 185.0,
		"vehicle_type": "hatchback",
		"estimated_hours": 1.0,
		"required_tool_ids": ["socket_set", "floor_jack", "jack_stands"],
		"steps_total": 6,
	},
	{
		"job_id": "front_struts_001",
		"display_name": "Front Strut Replacement",
		"description": "Both front struts are blown, full strut assembly replacement.",
		"tier": 3,
		"base_payout": 380.0,
		"vehicle_type": "sedan",
		"estimated_hours": 2.5,
		"required_tool_ids": ["socket_set", "floor_jack", "jack_stands", "torque_wrench"],
		"steps_total": 8,
	},
]

func _ready() -> void:
	EventBus.time_changed.connect(_on_time_changed)
	EventBus.job_completed.connect(_on_job_completed)
	EventBus.customer_departed.connect(_on_customer_departed)
	_next_threshold = randf_range(min_wait_hours, max_wait_hours)

func _on_time_changed(hour: float) -> void:
	if _customer_active:
		return
	_hours_since_last_customer += 1.0
	if _hours_since_last_customer >= _next_threshold and TimeManager.is_store_open():
		spawn_customer()

func _on_job_completed(_job_id: String, _payout: float) -> void:
	_customer_active = false
	_hours_since_last_customer = 0.0
	_next_threshold = randf_range(min_wait_hours, max_wait_hours)

func _on_customer_departed() -> void:
	_customer_active = false

func spawn_customer() -> void:
	if _job_pool.is_empty():
		return
	_customer_active = true
	_hours_since_last_customer = 0.0
	var job: Dictionary = _job_pool[randi() % _job_pool.size()]
	EventBus.customer_arrived.emit(job["job_id"])
