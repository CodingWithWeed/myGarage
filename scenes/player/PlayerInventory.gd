extends Node
class_name PlayerInventory

signal item_picked_up(item_id: String)
signal item_dropped(item_id: String)

var held_item_id: String = ""
var storage: Array[String] = []
var tools: Array[String] = [
	"socket_set",
	"oil_drain_pan",
	"floor_jack",
	"jack_stands",
	"screwdriver_set",
]

func pick_up(item_id: String) -> bool:
	if held_item_id != "":
		return false
	held_item_id = item_id
	item_picked_up.emit(item_id)
	return true

func drop_held() -> String:
	if held_item_id == "":
		return ""
	var dropped := held_item_id
	held_item_id = ""
	item_dropped.emit(dropped)
	return dropped

func has_tool(tool_id: String) -> bool:
	return tool_id in tools

func add_tool(tool_id: String) -> void:
	if tool_id not in tools:
		tools.append(tool_id)

func add_to_storage(item_id: String) -> void:
	storage.append(item_id)

func remove_from_storage(item_id: String) -> bool:
	var idx := storage.find(item_id)
	if idx == -1:
		return false
	storage.remove_at(idx)
	return true

func has_item(item_id: String) -> bool:
	if held_item_id == item_id:
		return true
	return item_id in storage

func get_all_items() -> Array[String]:
	var all: Array[String] = []
	if held_item_id != "":
		all.append(held_item_id)
	all.append_array(storage)
	return all
