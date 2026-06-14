extends Node

# All parts keyed by part_id. Each entry is a Dictionary with fields:
# id, name, category, source ("store"|"junkyard"), cost, weight,
# install_slot, dependencies (Array of slot_ids that must be filled first),
# restorable (bool), restoration_type ("machine_shop"|"workbench"|"")
var parts: Dictionary = {}

func _ready() -> void:
	_register_junkyard_parts()
	_register_store_parts()

func _add(id: String, name: String, category: String, source: String, cost: float,
		install_slot: String, deps: Array = [], restorable: bool = false,
		restoration_type: String = "", weight: float = 5.0) -> void:
	parts[id] = {
		"id": id, "name": name, "category": category, "source": source,
		"cost": cost, "weight": weight, "install_slot": install_slot,
		"dependencies": deps, "restorable": restorable,
		"restoration_type": restoration_type,
	}

func _register_junkyard_parts() -> void:
	# --- Engine (junkyard) ---
	_add("engine_block", "Engine Block (M52B28)", "engine", "junkyard", 180.0, "engine_block_slot", [], true, "machine_shop", 120.0)
	_add("cylinder_head", "Cylinder Head", "engine", "junkyard", 120.0, "cylinder_head_slot", ["engine_block_slot"], true, "machine_shop", 25.0)
	_add("crankshaft", "Crankshaft", "engine", "junkyard", 85.0, "crankshaft_slot", ["engine_block_slot"], true, "machine_shop", 18.0)
	_add("connecting_rods", "Connecting Rods Set x6", "engine", "junkyard", 55.0, "connecting_rods_slot", ["crankshaft_slot"], false, "", 4.0)
	_add("pistons", "Pistons Set x6", "engine", "junkyard", 65.0, "pistons_slot", ["connecting_rods_slot"], false, "", 3.0)
	_add("camshaft_intake", "Intake Camshaft", "engine", "junkyard", 65.0, "camshaft_intake_slot", ["cylinder_head_slot"], false, "", 4.0)
	_add("camshaft_exhaust", "Exhaust Camshaft", "engine", "junkyard", 60.0, "camshaft_exhaust_slot", ["cylinder_head_slot"], false, "", 4.0)
	_add("vanos_unit", "VANOS Unit", "engine", "junkyard", 95.0, "vanos_unit_slot", ["camshaft_intake_slot", "camshaft_exhaust_slot"], false, "", 3.0)
	_add("oil_pump", "Oil Pump", "engine", "junkyard", 40.0, "oil_pump_slot", ["engine_block_slot"], false, "", 2.0)
	_add("oil_pan", "Oil Pan", "engine", "junkyard", 35.0, "oil_pan_slot", ["oil_pump_slot"], false, "", 3.0)
	_add("flywheel", "Flywheel", "drivetrain", "junkyard", 55.0, "flywheel_slot", ["engine_block_slot"], true, "machine_shop", 8.0)
	_add("gearbox", "ZF 5-Speed Gearbox", "drivetrain", "junkyard", 160.0, "gearbox_slot", ["flywheel_slot"], false, "", 30.0)
	_add("rear_differential", "Rear Differential (LSD)", "drivetrain", "junkyard", 140.0, "rear_differential_slot", ["rear_subframe_slot"], false, "", 20.0)
	_add("prop_shaft", "Prop Shaft", "drivetrain", "junkyard", 60.0, "prop_shaft_slot", ["gearbox_slot", "rear_differential_slot"], false, "", 8.0)
	_add("rear_axle_shaft_left", "Rear Axle Shaft Left", "drivetrain", "junkyard", 30.0, "rear_axle_shaft_left_slot", ["rear_differential_slot"], false, "", 3.0)
	_add("rear_axle_shaft_right", "Rear Axle Shaft Right", "drivetrain", "junkyard", 30.0, "rear_axle_shaft_right_slot", ["rear_differential_slot"], false, "", 3.0)
	# --- Suspension arms (junkyard) ---
	_add("front_subframe", "Front Subframe", "suspension", "junkyard", 80.0, "front_subframe_slot", [], false, "", 25.0)
	_add("rear_subframe", "Rear Subframe", "suspension", "junkyard", 75.0, "rear_subframe_slot", [], false, "", 22.0)
	_add("front_lower_control_arm_left", "Front Lower Control Arm Left", "suspension", "junkyard", 30.0, "front_lower_control_arm_left_slot", ["front_subframe_slot"], false, "", 3.0)
	_add("front_lower_control_arm_right", "Front Lower Control Arm Right", "suspension", "junkyard", 30.0, "front_lower_control_arm_right_slot", ["front_subframe_slot"], false, "", 3.0)
	_add("rear_upper_control_arm_left", "Rear Upper Control Arm Left", "suspension", "junkyard", 35.0, "rear_upper_control_arm_left_slot", ["rear_subframe_slot"], false, "", 2.0)
	_add("rear_upper_control_arm_right", "Rear Upper Control Arm Right", "suspension", "junkyard", 35.0, "rear_upper_control_arm_right_slot", ["rear_subframe_slot"], false, "", 2.0)
	_add("rear_trailing_arm_left", "Rear Trailing Arm Left", "suspension", "junkyard", 40.0, "rear_trailing_arm_left_slot", ["rear_subframe_slot"], false, "", 4.0)
	_add("rear_trailing_arm_right", "Rear Trailing Arm Right", "suspension", "junkyard", 40.0, "rear_trailing_arm_right_slot", ["rear_subframe_slot"], false, "", 4.0)
	# --- Body panels (junkyard, workbench restoration) ---
	_add("hood", "Hood / Bonnet", "body", "junkyard", 45.0, "hood_slot", [], true, "workbench", 12.0)
	_add("front_bumper", "Front Bumper", "body", "junkyard", 35.0, "front_bumper_slot", [], true, "workbench", 8.0)
	_add("rear_bumper", "Rear Bumper", "body", "junkyard", 30.0, "rear_bumper_slot", [], true, "workbench", 7.0)
	_add("front_fender_left", "Front Fender Left", "body", "junkyard", 40.0, "front_fender_left_slot", [], true, "workbench", 6.0)
	_add("front_fender_right", "Front Fender Right", "body", "junkyard", 40.0, "front_fender_right_slot", [], true, "workbench", 6.0)
	_add("front_door_left", "Front Door Left", "body", "junkyard", 55.0, "front_door_left_slot", [], true, "workbench", 14.0)
	_add("front_door_right", "Front Door Right", "body", "junkyard", 55.0, "front_door_right_slot", [], true, "workbench", 14.0)
	_add("rear_door_left", "Rear Door Left", "body", "junkyard", 50.0, "rear_door_left_slot", [], true, "workbench", 13.0)
	_add("rear_door_right", "Rear Door Right", "body", "junkyard", 50.0, "rear_door_right_slot", [], true, "workbench", 13.0)
	_add("trunk_lid", "Trunk Lid", "body", "junkyard", 40.0, "trunk_lid_slot", [], true, "workbench", 10.0)
	_add("quarter_panel_left", "Quarter Panel Left", "body", "junkyard", 50.0, "quarter_panel_left_slot", [], true, "workbench", 8.0)
	_add("quarter_panel_right", "Quarter Panel Right", "body", "junkyard", 50.0, "quarter_panel_right_slot", [], true, "workbench", 8.0)
	_add("sill_left", "Sill Panel Left", "body", "junkyard", 25.0, "sill_left_slot", [], true, "workbench", 4.0)
	_add("sill_right", "Sill Panel Right", "body", "junkyard", 25.0, "sill_right_slot", [], true, "workbench", 4.0)
	# --- Interior majors (junkyard) ---
	_add("dashboard", "Dashboard Shell", "interior", "junkyard", 75.0, "dashboard_slot", [], false, "", 8.0)
	_add("drivers_seat", "Driver Seat", "interior", "junkyard", 60.0, "drivers_seat_slot", [], false, "", 18.0)
	_add("passenger_seat", "Passenger Seat", "interior", "junkyard", 55.0, "passenger_seat_slot", [], false, "", 18.0)
	_add("rear_seat_bottom", "Rear Seat Bottom", "interior", "junkyard", 35.0, "rear_seat_bottom_slot", [], false, "", 8.0)
	_add("rear_seat_back", "Rear Seat Back", "interior", "junkyard", 40.0, "rear_seat_back_slot", [], false, "", 6.0)
	_add("headliner", "Headliner", "interior", "junkyard", 45.0, "headliner_slot", [], false, "", 3.0)
	_add("door_card_front_left", "Door Card Front Left", "interior", "junkyard", 20.0, "door_card_front_left_slot", ["front_door_left_slot"], false, "", 2.0)
	_add("door_card_front_right", "Door Card Front Right", "interior", "junkyard", 20.0, "door_card_front_right_slot", ["front_door_right_slot"], false, "", 2.0)

func _register_store_parts() -> void:
	# --- Engine internals (store) ---
	_add("head_gasket", "Head Gasket", "engine", "store", 55.0, "head_gasket_slot", ["engine_block_slot"], false, "", 0.5)
	_add("head_bolts", "Head Bolts Set x14", "engine", "store", 30.0, "head_bolts_slot", ["head_gasket_slot"], false, "", 1.0)
	_add("main_bearings", "Main Bearings Set x7", "engine", "store", 45.0, "main_bearings_slot", ["crankshaft_slot"], false, "", 0.5)
	_add("rod_bearings", "Rod Bearings Set x6", "engine", "store", 40.0, "rod_bearings_slot", ["connecting_rods_slot"], false, "", 0.3)
	_add("piston_rings", "Piston Rings Set x6", "engine", "store", 55.0, "piston_rings_slot", ["pistons_slot"], false, "", 0.3)
	_add("timing_chain", "Timing Chain", "engine", "store", 65.0, "timing_chain_slot", ["crankshaft_slot"], false, "", 1.0)
	_add("timing_chain_tensioner", "Timing Chain Tensioner", "engine", "store", 35.0, "timing_chain_tensioner_slot", ["timing_chain_slot"], false, "", 0.3)
	_add("timing_chain_guide_upper", "Timing Chain Guide Upper", "engine", "store", 20.0, "timing_chain_guide_upper_slot", ["timing_chain_slot"], false, "", 0.2)
	_add("timing_chain_guide_lower", "Timing Chain Guide Lower", "engine", "store", 20.0, "timing_chain_guide_lower_slot", ["timing_chain_slot"], false, "", 0.2)
	_add("valve_cover", "Valve Cover", "engine", "store", 45.0, "valve_cover_slot", ["camshaft_intake_slot"], false, "", 2.0)
	_add("valve_cover_gasket", "Valve Cover Gasket", "engine", "store", 18.0, "valve_cover_gasket_slot", [], false, "", 0.1)
	_add("intake_valves", "Intake Valves Set x12", "engine", "store", 90.0, "intake_valves_slot", ["cylinder_head_slot"], false, "", 1.0)
	_add("exhaust_valves", "Exhaust Valves Set x12", "engine", "store", 90.0, "exhaust_valves_slot", ["cylinder_head_slot"], false, "", 1.0)
	_add("valve_springs", "Valve Springs Set x24", "engine", "store", 75.0, "valve_springs_slot", ["intake_valves_slot", "exhaust_valves_slot"], false, "", 0.5)
	_add("valve_stem_seals", "Valve Stem Seals Set x24", "engine", "store", 35.0, "valve_stem_seals_slot", ["intake_valves_slot"], false, "", 0.1)
	_add("cam_sprockets", "Cam Sprockets Pair", "engine", "store", 60.0, "cam_sprockets_slot", ["camshaft_intake_slot", "camshaft_exhaust_slot"], false, "", 1.0)
	# --- Lubrication (store) ---
	_add("oil_filter_housing", "Oil Filter Housing", "engine", "store", 45.0, "oil_filter_housing_slot", ["engine_block_slot"], false, "", 1.0)
	_add("oil_filter", "Oil Filter", "engine", "store", 12.0, "oil_filter_slot", ["oil_filter_housing_slot"], false, "", 0.3)
	_add("oil_drain_plug", "Oil Drain Plug", "engine", "store", 5.0, "oil_drain_plug_slot", ["oil_pan_slot"], false, "", 0.1)
	_add("engine_oil_5l", "Engine Oil 5L", "consumable", "store", 28.0, "engine_oil_slot", [], false, "", 5.0)
	# --- Cooling (store) ---
	_add("water_pump", "Water Pump", "engine", "store", 65.0, "water_pump_slot", ["engine_block_slot"], false, "", 2.0)
	_add("thermostat", "Thermostat", "engine", "store", 22.0, "thermostat_slot", ["engine_block_slot"], false, "", 0.2)
	_add("thermostat_housing", "Thermostat Housing", "engine", "store", 35.0, "thermostat_housing_slot", ["thermostat_slot"], false, "", 0.5)
	_add("radiator", "Radiator", "engine", "store", 130.0, "radiator_slot", [], false, "", 6.0)
	_add("radiator_hose_upper", "Radiator Hose Upper", "engine", "store", 18.0, "radiator_hose_upper_slot", ["radiator_slot", "thermostat_housing_slot"], false, "", 0.3)
	_add("radiator_hose_lower", "Radiator Hose Lower", "engine", "store", 18.0, "radiator_hose_lower_slot", ["radiator_slot", "water_pump_slot"], false, "", 0.3)
	_add("coolant_expansion_tank", "Coolant Expansion Tank", "engine", "store", 40.0, "coolant_expansion_tank_slot", [], false, "", 1.0)
	_add("coolant_5l", "Coolant 5L", "consumable", "store", 25.0, "coolant_slot", [], false, "", 5.0)
	_add("cooling_fan", "Electric Cooling Fan", "engine", "store", 55.0, "cooling_fan_slot", ["radiator_slot"], false, "", 2.0)
	# --- Fuel system (store) ---
	_add("fuel_tank", "Fuel Tank", "engine", "store", 180.0, "fuel_tank_slot", [], false, "", 10.0)
	_add("fuel_pump", "Fuel Pump (in-tank)", "engine", "store", 85.0, "fuel_pump_slot", ["fuel_tank_slot"], false, "", 1.0)
	_add("fuel_filter", "Fuel Filter", "engine", "store", 22.0, "fuel_filter_slot", ["fuel_pump_slot"], false, "", 0.3)
	_add("fuel_rail", "Fuel Rail", "engine", "store", 75.0, "fuel_rail_slot", ["intake_manifold_slot"], false, "", 1.0)
	_add("fuel_injectors", "Fuel Injectors Set x6", "engine", "store", 210.0, "fuel_injectors_slot", ["fuel_rail_slot"], false, "", 1.0)
	_add("fuel_pressure_regulator", "Fuel Pressure Regulator", "engine", "store", 45.0, "fuel_pressure_regulator_slot", ["fuel_rail_slot"], false, "", 0.3)
	# --- Intake (store) ---
	_add("intake_manifold", "Intake Manifold", "engine", "store", 120.0, "intake_manifold_slot", ["cylinder_head_slot"], false, "", 4.0)
	_add("intake_manifold_gaskets", "Intake Manifold Gaskets", "engine", "store", 28.0, "intake_manifold_gaskets_slot", ["intake_manifold_slot"], false, "", 0.1)
	_add("throttle_body", "Throttle Body", "engine", "store", 85.0, "throttle_body_slot", ["intake_manifold_slot"], false, "", 1.0)
	_add("idle_control_valve", "Idle Control Valve", "engine", "store", 55.0, "idle_control_valve_slot", ["throttle_body_slot"], false, "", 0.3)
	_add("maf_sensor", "Mass Airflow Sensor (MAF)", "engine", "store", 90.0, "maf_sensor_slot", [], false, "", 0.3)
	_add("air_filter_housing", "Air Filter Housing", "engine", "store", 35.0, "air_filter_housing_slot", [], false, "", 1.0)
	_add("air_filter", "Air Filter", "engine", "store", 18.0, "air_filter_slot", ["air_filter_housing_slot"], false, "", 0.3)
	# --- Engine ancillaries (store) ---
	_add("alternator", "Alternator", "engine", "store", 145.0, "alternator_slot", ["engine_block_slot"], false, "", 5.0)
	_add("alternator_belt", "Alternator Belt", "engine", "store", 22.0, "alternator_belt_slot", ["alternator_slot"], false, "", 0.2)
	_add("water_pump_belt", "Water Pump Belt", "engine", "store", 20.0, "water_pump_belt_slot", ["water_pump_slot"], false, "", 0.2)
	_add("engine_mounts", "Engine Mounts Pair", "engine", "store", 80.0, "engine_mounts_slot", ["engine_block_slot", "front_subframe_slot"], false, "", 2.0)
	_add("harmonic_balancer", "Harmonic Balancer", "engine", "store", 65.0, "harmonic_balancer_slot", ["crankshaft_slot"], false, "", 2.0)
	# --- Electrical (store) ---
	_add("starter_motor", "Starter Motor", "engine", "store", 110.0, "starter_motor_slot", ["engine_block_slot"], false, "", 4.0)
	_add("ignition_coil_pack", "Ignition Coil Pack x6", "engine", "store", 180.0, "ignition_coil_pack_slot", ["spark_plugs_set_slot"], false, "", 2.0)
	_add("spark_plugs_set", "Spark Plugs Set x6", "engine", "store", 45.0, "spark_plugs_set_slot", ["cylinder_head_slot"], false, "", 0.3)
	_add("crank_position_sensor", "Crank Position Sensor", "electrical", "store", 55.0, "crank_position_sensor_slot", ["engine_block_slot"], false, "", 0.2)
	_add("cam_position_sensor", "Cam Position Sensor", "electrical", "store", 50.0, "cam_position_sensor_slot", ["cylinder_head_slot"], false, "", 0.2)
	_add("coolant_temp_sensor", "Coolant Temp Sensor", "electrical", "store", 28.0, "coolant_temp_sensor_slot", ["thermostat_housing_slot"], false, "", 0.1)
	_add("oil_pressure_sensor", "Oil Pressure Sensor", "electrical", "store", 25.0, "oil_pressure_sensor_slot", ["engine_block_slot"], false, "", 0.1)
	_add("knock_sensor", "Knock Sensor", "electrical", "store", 40.0, "knock_sensor_slot", ["engine_block_slot"], false, "", 0.1)
	_add("throttle_position_sensor", "Throttle Position Sensor", "electrical", "store", 45.0, "throttle_position_sensor_slot", ["throttle_body_slot"], false, "", 0.1)
	_add("oxygen_sensor_pre_cat", "O2 Sensor Pre-Cat", "electrical", "store", 65.0, "oxygen_sensor_pre_cat_slot", ["exhaust_manifold_slot"], false, "", 0.2)
	_add("oxygen_sensor_post_cat", "O2 Sensor Post-Cat", "electrical", "store", 55.0, "oxygen_sensor_post_cat_slot", ["catalytic_converter_slot"], false, "", 0.2)
	_add("ecu", "ECU (DME MS41 Reconditioned)", "electrical", "store", 380.0, "ecu_slot", [], false, "", 1.0)
	_add("ecu_bracket", "ECU Mounting Bracket", "electrical", "store", 25.0, "ecu_bracket_slot", [], false, "", 0.3)
	_add("engine_bay_loom", "Engine Bay Wiring Loom", "electrical", "store", 320.0, "engine_bay_loom_slot", ["ecu_slot"], false, "", 2.0)
	_add("interior_loom", "Interior Wiring Loom", "electrical", "store", 280.0, "interior_loom_slot", [], false, "", 2.0)
	_add("fuse_box_engine", "Fuse Box (Engine Bay)", "electrical", "store", 110.0, "fuse_box_engine_slot", ["engine_bay_loom_slot"], false, "", 0.5)
	_add("fuse_box_interior", "Fuse Box (Interior)", "electrical", "store", 95.0, "fuse_box_interior_slot", ["interior_loom_slot"], false, "", 0.5)
	_add("battery", "Battery", "electrical", "store", 120.0, "battery_slot", [], false, "", 14.0)
	_add("battery_tray", "Battery Tray", "electrical", "store", 30.0, "battery_tray_slot", [], false, "", 1.0)
	_add("battery_cables", "Battery Cables (pos + neg)", "electrical", "store", 35.0, "battery_cables_slot", ["battery_slot"], false, "", 0.5)
	_add("instrument_cluster", "Instrument Cluster", "electrical", "store", 175.0, "instrument_cluster_slot", ["dashboard_slot", "interior_loom_slot"], false, "", 1.5)
	# --- Suspension consumables (store) ---
	_add("front_strut_left", "Front Strut Left", "suspension", "store", 90.0, "front_strut_left_slot", ["front_subframe_slot"], false, "", 5.0)
	_add("front_strut_right", "Front Strut Right", "suspension", "store", 90.0, "front_strut_right_slot", ["front_subframe_slot"], false, "", 5.0)
	_add("front_coil_spring_left", "Front Coil Spring Left", "suspension", "store", 45.0, "front_coil_spring_left_slot", ["front_strut_left_slot"], false, "", 4.0)
	_add("front_coil_spring_right", "Front Coil Spring Right", "suspension", "store", 45.0, "front_coil_spring_right_slot", ["front_strut_right_slot"], false, "", 4.0)
	_add("front_strut_mount_left", "Front Strut Mount Left", "suspension", "store", 28.0, "front_strut_mount_left_slot", ["front_coil_spring_left_slot"], false, "", 0.5)
	_add("front_strut_mount_right", "Front Strut Mount Right", "suspension", "store", 28.0, "front_strut_mount_right_slot", ["front_coil_spring_right_slot"], false, "", 0.5)
	_add("front_ball_joint_left", "Front Ball Joint Left", "suspension", "store", 32.0, "front_ball_joint_left_slot", ["front_lower_control_arm_left_slot"], false, "", 0.5)
	_add("front_ball_joint_right", "Front Ball Joint Right", "suspension", "store", 32.0, "front_ball_joint_right_slot", ["front_lower_control_arm_right_slot"], false, "", 0.5)
	_add("front_wheel_bearing_left", "Front Wheel Bearing Left", "suspension", "store", 38.0, "front_wheel_bearing_left_slot", ["front_strut_left_slot"], false, "", 1.0)
	_add("front_wheel_bearing_right", "Front Wheel Bearing Right", "suspension", "store", 38.0, "front_wheel_bearing_right_slot", ["front_strut_right_slot"], false, "", 1.0)
	_add("front_hub_left", "Front Hub Left", "suspension", "store", 30.0, "front_hub_left_slot", ["front_wheel_bearing_left_slot"], false, "", 2.0)
	_add("front_hub_right", "Front Hub Right", "suspension", "store", 30.0, "front_hub_right_slot", ["front_wheel_bearing_right_slot"], false, "", 2.0)
	_add("front_anti_roll_bar", "Front Anti-Roll Bar", "suspension", "store", 60.0, "front_anti_roll_bar_slot", ["front_subframe_slot"], false, "", 3.0)
	_add("front_arb_links", "Front ARB Drop Links Pair", "suspension", "store", 30.0, "front_arb_links_slot", ["front_anti_roll_bar_slot"], false, "", 0.5)
	_add("rear_shock_left", "Rear Shock Absorber Left", "suspension", "store", 80.0, "rear_shock_left_slot", ["rear_subframe_slot"], false, "", 4.0)
	_add("rear_shock_right", "Rear Shock Absorber Right", "suspension", "store", 80.0, "rear_shock_right_slot", ["rear_subframe_slot"], false, "", 4.0)
	_add("rear_coil_spring_left", "Rear Coil Spring Left", "suspension", "store", 42.0, "rear_coil_spring_left_slot", ["rear_shock_left_slot"], false, "", 3.5)
	_add("rear_coil_spring_right", "Rear Coil Spring Right", "suspension", "store", 42.0, "rear_coil_spring_right_slot", ["rear_shock_right_slot"], false, "", 3.5)
	_add("rear_wheel_bearing_left", "Rear Wheel Bearing Left", "suspension", "store", 35.0, "rear_wheel_bearing_left_slot", ["rear_trailing_arm_left_slot"], false, "", 1.0)
	_add("rear_wheel_bearing_right", "Rear Wheel Bearing Right", "suspension", "store", 35.0, "rear_wheel_bearing_right_slot", ["rear_trailing_arm_right_slot"], false, "", 1.0)
	_add("rear_hub_left", "Rear Hub Left", "suspension", "store", 28.0, "rear_hub_left_slot", ["rear_wheel_bearing_left_slot"], false, "", 2.0)
	_add("rear_hub_right", "Rear Hub Right", "suspension", "store", 28.0, "rear_hub_right_slot", ["rear_wheel_bearing_right_slot"], false, "", 2.0)
	_add("rear_anti_roll_bar", "Rear Anti-Roll Bar", "suspension", "store", 55.0, "rear_anti_roll_bar_slot", ["rear_subframe_slot"], false, "", 3.0)
	_add("rear_arb_links", "Rear ARB Drop Links Pair", "suspension", "store", 28.0, "rear_arb_links_slot", ["rear_anti_roll_bar_slot"], false, "", 0.5)
	# --- Clutch (store) ---
	_add("clutch_disc", "Clutch Disc", "drivetrain", "store", 85.0, "clutch_disc_slot", ["gearbox_slot", "flywheel_slot"], false, "", 2.0)
	_add("pressure_plate", "Pressure Plate", "drivetrain", "store", 75.0, "pressure_plate_slot", ["clutch_disc_slot"], false, "", 3.0)
	_add("clutch_release_bearing", "Clutch Release Bearing", "drivetrain", "store", 30.0, "clutch_release_bearing_slot", ["clutch_disc_slot"], false, "", 0.3)
	_add("gearbox_mount", "Gearbox Mount", "drivetrain", "store", 35.0, "gearbox_mount_slot", ["gearbox_slot"], false, "", 1.0)
	_add("cv_joints_rear", "CV Joints Rear Pair", "drivetrain", "store", 95.0, "cv_joints_rear_slot", ["rear_axle_shaft_left_slot", "rear_axle_shaft_right_slot"], false, "", 2.0)
	# --- Steering (store) ---
	_add("steering_rack", "Steering Rack", "steering", "store", 175.0, "steering_rack_slot", ["front_subframe_slot"], false, "", 8.0)
	_add("steering_rack_boots", "Steering Rack Boots Pair", "steering", "store", 22.0, "steering_rack_boots_slot", ["steering_rack_slot"], false, "", 0.2)
	_add("tie_rod_left", "Tie Rod Left", "steering", "store", 32.0, "tie_rod_left_slot", ["steering_rack_slot"], false, "", 0.5)
	_add("tie_rod_right", "Tie Rod Right", "steering", "store", 32.0, "tie_rod_right_slot", ["steering_rack_slot"], false, "", 0.5)
	_add("tie_rod_end_left", "Tie Rod End Left", "steering", "store", 22.0, "tie_rod_end_left_slot", ["tie_rod_left_slot"], false, "", 0.3)
	_add("tie_rod_end_right", "Tie Rod End Right", "steering", "store", 22.0, "tie_rod_end_right_slot", ["tie_rod_right_slot"], false, "", 0.3)
	_add("steering_column", "Steering Column", "steering", "store", 95.0, "steering_column_slot", [], false, "", 3.0)
	_add("steering_wheel", "Steering Wheel", "steering", "store", 75.0, "steering_wheel_slot", ["steering_column_slot"], false, "", 2.0)
	_add("power_steering_pump", "Power Steering Pump", "steering", "store", 110.0, "power_steering_pump_slot", ["engine_block_slot"], false, "", 4.0)
	# --- Brakes (store) ---
	_add("front_brake_disc_left", "Front Brake Disc Left", "brakes", "store", 45.0, "front_brake_disc_left_slot", ["front_hub_left_slot"], false, "", 4.0)
	_add("front_brake_disc_right", "Front Brake Disc Right", "brakes", "store", 45.0, "front_brake_disc_right_slot", ["front_hub_right_slot"], false, "", 4.0)
	_add("front_brake_pads", "Front Brake Pads Set", "brakes", "store", 35.0, "front_brake_pads_slot", ["front_brake_disc_left_slot", "front_brake_disc_right_slot"], false, "", 1.0)
	_add("front_caliper_left", "Front Brake Caliper Left", "brakes", "store", 70.0, "front_caliper_left_slot", ["front_brake_disc_left_slot"], false, "", 3.0)
	_add("front_caliper_right", "Front Brake Caliper Right", "brakes", "store", 70.0, "front_caliper_right_slot", ["front_brake_disc_right_slot"], false, "", 3.0)
	_add("rear_brake_disc_left", "Rear Brake Disc Left", "brakes", "store", 40.0, "rear_brake_disc_left_slot", ["rear_hub_left_slot"], false, "", 3.5)
	_add("rear_brake_disc_right", "Rear Brake Disc Right", "brakes", "store", 40.0, "rear_brake_disc_right_slot", ["rear_hub_right_slot"], false, "", 3.5)
	_add("rear_brake_pads", "Rear Brake Pads Set", "brakes", "store", 30.0, "rear_brake_pads_slot", ["rear_brake_disc_left_slot", "rear_brake_disc_right_slot"], false, "", 1.0)
	_add("rear_caliper_left", "Rear Brake Caliper Left", "brakes", "store", 60.0, "rear_caliper_left_slot", ["rear_brake_disc_left_slot"], false, "", 2.5)
	_add("rear_caliper_right", "Rear Brake Caliper Right", "brakes", "store", 60.0, "rear_caliper_right_slot", ["rear_brake_disc_right_slot"], false, "", 2.5)
	_add("brake_master_cylinder", "Brake Master Cylinder", "brakes", "store", 75.0, "brake_master_cylinder_slot", [], false, "", 2.0)
	_add("brake_servo", "Brake Servo (Booster)", "brakes", "store", 95.0, "brake_servo_slot", ["brake_master_cylinder_slot"], false, "", 3.0)
	_add("brake_lines", "Brake Lines Set", "brakes", "store", 65.0, "brake_lines_slot", ["brake_master_cylinder_slot"], false, "", 1.5)
	_add("brake_fluid", "Brake Fluid 1L", "consumable", "store", 12.0, "brake_fluid_slot", [], false, "", 1.0)
	_add("handbrake_cables", "Handbrake Cables Pair", "brakes", "store", 40.0, "handbrake_cables_slot", ["rear_caliper_left_slot", "rear_caliper_right_slot"], false, "", 1.0)
	# --- Exhaust (store) ---
	_add("exhaust_manifold", "Exhaust Manifold", "exhaust", "store", 120.0, "exhaust_manifold_slot", ["cylinder_head_slot"], false, "", 6.0)
	_add("exhaust_manifold_gaskets", "Exhaust Manifold Gaskets", "exhaust", "store", 25.0, "exhaust_manifold_gaskets_slot", ["exhaust_manifold_slot"], false, "", 0.1)
	_add("catalytic_converter", "Catalytic Converter", "exhaust", "store", 180.0, "catalytic_converter_slot", ["exhaust_manifold_slot"], false, "", 5.0)
	_add("front_pipe", "Exhaust Front Pipe", "exhaust", "store", 70.0, "front_pipe_slot", ["catalytic_converter_slot"], false, "", 3.0)
	_add("mid_pipe", "Exhaust Mid Pipe", "exhaust", "store", 55.0, "mid_pipe_slot", ["front_pipe_slot"], false, "", 2.5)
	_add("centre_silencer", "Centre Silencer (Resonator)", "exhaust", "store", 65.0, "centre_silencer_slot", ["mid_pipe_slot"], false, "", 3.0)
	_add("rear_muffler", "Rear Muffler", "exhaust", "store", 85.0, "rear_muffler_slot", ["centre_silencer_slot"], false, "", 4.0)
	_add("tail_pipe", "Tail Pipe", "exhaust", "store", 30.0, "tail_pipe_slot", ["rear_muffler_slot"], false, "", 1.0)
	# --- Interior consumables (store) ---
	_add("carpet_set", "Carpet Set (Full)", "interior", "store", 90.0, "carpet_set_slot", [], false, "", 4.0)
	_add("centre_console", "Centre Console", "interior", "store", 85.0, "centre_console_slot", [], false, "", 3.0)
	_add("gear_lever", "Gear Lever", "interior", "store", 45.0, "gear_lever_slot", ["gearbox_slot", "centre_console_slot"], false, "", 1.0)
	_add("gear_lever_gaiter", "Gear Lever Gaiter", "interior", "store", 18.0, "gear_lever_gaiter_slot", ["gear_lever_slot"], false, "", 0.2)
	_add("seat_rails", "Seat Rails Set x4", "interior", "store", 55.0, "seat_rails_slot", [], false, "", 4.0)
	_add("windscreen", "Windscreen", "body", "store", 180.0, "windscreen_slot", [], false, "", 12.0)
	_add("windscreen_seal", "Windscreen Seal", "body", "store", 30.0, "windscreen_seal_slot", ["windscreen_slot"], false, "", 0.5)
	_add("rear_screen", "Rear Screen", "body", "store", 145.0, "rear_screen_slot", [], false, "", 10.0)
	_add("rear_screen_seal", "Rear Screen Seal", "body", "store", 25.0, "rear_screen_seal_slot", ["rear_screen_slot"], false, "", 0.3)
	_add("door_seals", "Door Seals Set x4", "body", "store", 65.0, "door_seals_slot", [], false, "", 1.0)
	# --- Wheels & tyres (store) ---
	_add("wheels_set", "Wheel Rims Set x4", "wheels", "store", 280.0, "wheels_set_slot", [], false, "", 40.0)
	_add("tyres_set", "Tyres Set x4", "wheels", "store", 220.0, "tyres_set_slot", ["wheels_set_slot"], false, "", 30.0)
	_add("wheel_bolts", "Wheel Bolts Set x20", "wheels", "store", 30.0, "wheel_bolts_slot", ["wheels_set_slot"], false, "", 1.0)

func get_part(part_id: String) -> Dictionary:
	return parts.get(part_id, {})

func get_parts_by_category(category: String) -> Array:
	var result := []
	for p in parts.values():
		if p["category"] == category:
			result.append(p)
	return result

func get_junkyard_parts() -> Array:
	var result := []
	for p in parts.values():
		if p["source"] == "junkyard":
			result.append(p)
	return result

func get_store_parts() -> Array:
	var result := []
	for p in parts.values():
		if p["source"] == "store":
			result.append(p)
	return result

func get_machining_days(part_id: String) -> int:
	match part_id:
		"engine_block": return 3
		"cylinder_head": return 2
		"crankshaft", "flywheel": return 1
		_: return 1
