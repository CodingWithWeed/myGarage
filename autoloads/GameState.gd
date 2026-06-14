extends Node

var flags: Dictionary = {
	"e36_started_first_time": false,
	"tutorial_complete": false,
	"met_pete": false,
	"met_ivan": false,
	"met_tomas": false,
}

var e36_slots: Dictionary = {}
var active_jobs: Array = []
var completed_jobs_count: int = 0

# Machine shop orders: { part_id: ready_day }
var machine_shop_orders: Dictionary = {}

func set_flag(key: String, value) -> void:
	flags[key] = value

func get_flag(key: String, default = null):
	return flags.get(key, default)

func save_game(slot: int = 0) -> void:
	var data := {
		"version": 1,
		"wallet": Economy.get_balance(),
		"day": TimeManager.current_day,
		"time_of_day": TimeManager.current_hour,
		"player_position": [0.0, 0.0, 0.0],
		"e36_slots": e36_slots,
		"active_jobs": active_jobs,
		"completed_jobs_count": completed_jobs_count,
		"machine_shop_orders": machine_shop_orders,
		"flags": flags,
	}
	var file := FileAccess.open("user://save_slot_%d.json" % slot, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false
	var file := FileAccess.open("user://save_slot_%d.json" % slot, FileAccess.READ)
	if not file:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return false

	Economy.balance = float(data.get("wallet", 450.0))
	TimeManager.current_day = int(data.get("day", 1))
	TimeManager.current_hour = float(data.get("time_of_day", 8.0))
	e36_slots = data.get("e36_slots", {})
	active_jobs = data.get("active_jobs", [])
	completed_jobs_count = int(data.get("completed_jobs_count", 0))
	machine_shop_orders = data.get("machine_shop_orders", {})
	flags = data.get("flags", flags)

	EventBus.wallet_changed.emit(Economy.balance)
	EventBus.day_changed.emit(TimeManager.current_day)
	return true

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists("user://save_slot_%d.json" % slot)

func set_slot_filled(slot_id: String, part_id: String) -> void:
	e36_slots[slot_id] = {"filled": true, "part_id": part_id}

func set_slot_empty(slot_id: String) -> void:
	e36_slots[slot_id] = {"filled": false, "part_id": ""}

func is_slot_filled(slot_id: String) -> bool:
	return e36_slots.get(slot_id, {}).get("filled", false)

func add_machine_shop_order(part_id: String) -> void:
	var ready_day := TimeManager.current_day + PartCatalog.get_machining_days(part_id)
	machine_shop_orders[part_id] = ready_day
	EventBus.part_dropped_off_machine_shop.emit(part_id, ready_day)

func check_machine_shop_orders() -> void:
	for part_id in machine_shop_orders.keys():
		if TimeManager.current_day >= machine_shop_orders[part_id]:
			machine_shop_orders.erase(part_id)
			EventBus.part_ready_machine_shop.emit(part_id)
