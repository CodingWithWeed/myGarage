extends RigidBody3D
class_name CarPartNode3D

signal picked_up(part_id: String)
signal dropped(part_id: String)

@export var part_id: String = ""

var is_held: bool = false
var is_installed: bool = false
var _original_collision_layer: int = 0
var _original_collision_mask: int = 0
var _material: StandardMaterial3D = null
var _visual_meshes: Array[MeshInstance3D] = []
var _highlight_overlay: StandardMaterial3D = null

const CATEGORY_COLORS := {
	"engine": Color(0.8, 0.2, 0.1),
	"drivetrain": Color(0.8, 0.5, 0.0),
	"suspension": Color(0.1, 0.3, 0.8),
	"brakes": Color(0.7, 0.7, 0.0),
	"electrical": Color(0.0, 0.7, 0.7),
	"body": Color(0.4, 0.4, 0.4),
	"interior": Color(0.5, 0.2, 0.6),
	"exhaust": Color(0.5, 0.3, 0.1),
	"wheels": Color(0.15, 0.6, 0.15),
	"steering": Color(0.7, 0.3, 0.5),
	"consumable": Color(0.85, 0.85, 0.85),
}

const CATEGORY_BOX_SIZE := {
	"engine": Vector3(0.3, 0.2, 0.35),
	"drivetrain": Vector3(0.25, 0.2, 0.3),
	"suspension": Vector3(0.15, 0.35, 0.1),
	"brakes": Vector3(0.28, 0.06, 0.28),
	"electrical": Vector3(0.18, 0.1, 0.18),
	"body": Vector3(0.55, 0.05, 0.45),
	"interior": Vector3(0.4, 0.25, 0.45),
	"exhaust": Vector3(0.08, 0.08, 0.38),
	"wheels": Vector3(0.22, 0.55, 0.22),
	"steering": Vector3(0.1, 0.1, 0.35),
	"consumable": Vector3(0.1, 0.18, 0.1),
}

func _ready() -> void:
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	if part_id != "":
		call_deferred("_apply_category_material")

func _apply_category_material() -> void:
	var data := PartCatalog.get_part(part_id)
	if data.is_empty():
		return
	var category: String = data.get("category", "engine")
	var color: Color = CATEGORY_COLORS.get(category, Color(0.5, 0.5, 0.5))
	var size: Vector3 = CATEGORY_BOX_SIZE.get(category, Vector3(0.2, 0.2, 0.2))

	# Prefer the real model geometry; fall back to a coloured box.
	if PartVisuals.has_visual(part_id):
		var visual := PartVisuals.make_visual(part_id)
		if visual != null:
			var box_node := get_node_or_null("MeshInstance3D")
			if box_node is MeshInstance3D:
				(box_node as MeshInstance3D).visible = false
			add_child(visual)
			_collect_visual_meshes(visual)
			return

	var mesh_node := get_node_or_null("MeshInstance3D")
	if mesh_node is MeshInstance3D:
		var box := BoxMesh.new()
		box.size = size
		mesh_node.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.9
		mesh_node.material_override = mat
		_material = mat

	var col_node := get_node_or_null("CollisionShape3D")
	if col_node is CollisionShape3D:
		var shape := BoxShape3D.new()
		shape.size = size
		col_node.shape = shape

func _collect_visual_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		_visual_meshes.append(node as MeshInstance3D)
	for c in node.get_children():
		_collect_visual_meshes(c)

func set_highlighted(on: bool) -> void:
	# Box parts glow via their own material; real-mesh parts use a per-instance
	# overlay so the shared model materials aren't affected.
	if _material != null:
		_material.emission_enabled = on
		if on:
			_material.emission = _material.albedo_color.lightened(0.5)
			_material.emission_energy_multiplier = 0.6
	if not _visual_meshes.is_empty():
		if on and _highlight_overlay == null:
			_highlight_overlay = StandardMaterial3D.new()
			_highlight_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_highlight_overlay.albedo_color = Color(1.0, 1.0, 0.7, 0.18)
			_highlight_overlay.emission_enabled = true
			_highlight_overlay.emission = Color(1.0, 0.95, 0.5)
			_highlight_overlay.emission_energy_multiplier = 0.4
		for m in _visual_meshes:
			m.material_overlay = _highlight_overlay if on else null

func pick_up() -> void:
	set_highlighted(false)
	is_held = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	picked_up.emit(part_id)

func drop(drop_position: Vector3, impulse: Vector3 = Vector3.ZERO) -> void:
	is_held = false
	global_position = drop_position
	freeze = false
	collision_layer = _original_collision_layer
	collision_mask = _original_collision_mask
	if impulse != Vector3.ZERO:
		apply_central_impulse(impulse)
	dropped.emit(part_id)
