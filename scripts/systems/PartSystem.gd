extends Node
class_name PartSystem

# Slots required for the E36 engine to start
const STARTABLE_SLOTS := [
	"engine_block_slot",
	"crankshaft_slot",
	"main_bearings_slot",
	"oil_pump_slot",
	"oil_pan_slot",
	"oil_drain_plug_slot",
	"oil_filter_housing_slot",
	"oil_filter_slot",
	"engine_oil_slot",
	"cylinder_head_slot",
	"head_gasket_slot",
	"head_bolts_slot",
	"timing_chain_slot",
	"timing_chain_tensioner_slot",
	"camshaft_intake_slot",
	"camshaft_exhaust_slot",
	"vanos_unit_slot",
	"intake_manifold_slot",
	"throttle_body_slot",
	"water_pump_slot",
	"thermostat_slot",
	"thermostat_housing_slot",
	"radiator_slot",
	"radiator_hose_upper_slot",
	"radiator_hose_lower_slot",
	"coolant_slot",
	"spark_plugs_set_slot",
	"ignition_coil_pack_slot",
	"fuel_rail_slot",
	"fuel_injectors_slot",
	"fuel_pump_slot",
	"fuel_filter_slot",
	"alternator_slot",
	"starter_motor_slot",
	"ecu_slot",
	"engine_bay_loom_slot",
	"battery_slot",
	"battery_cables_slot",
	"exhaust_manifold_slot",
	"engine_mounts_slot",
]

func can_install(part_id: String, slot: InstallSlot, inventory: Node) -> bool:
	if slot.is_filled:
		return false
	if not slot.can_accept(part_id):
		return false
	if not inventory.has_item(part_id):
		return false
	for dep_slot_id in slot.dependency_slot_ids:
		if not GameState.is_slot_filled(dep_slot_id):
			return false
	return true

func install_part(part_id: String, slot: InstallSlot, inventory: Node) -> bool:
	if not can_install(part_id, slot, inventory):
		return false
	inventory.drop_held()
	slot.install_part(part_id)
	return true

func can_remove(slot: InstallSlot, inventory: Node) -> bool:
	if not slot.is_filled:
		return false
	if inventory.held_item_id != "":
		return false
	return true

func remove_part(slot: InstallSlot, inventory: Node) -> String:
	if not can_remove(slot, inventory):
		return ""
	var part_id := slot.remove_part()
	inventory.pick_up(part_id)
	return part_id

func is_e36_startable(slot_nodes: Array) -> bool:
	var filled_slots := {}
	for slot in slot_nodes:
		if slot is InstallSlot and slot.is_filled:
			filled_slots[slot.slot_id] = true
	for required in STARTABLE_SLOTS:
		if not filled_slots.has(required):
			return false
	return true
