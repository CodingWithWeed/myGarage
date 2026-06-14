extends Node

# Provides real part geometry (extracted from the imported E36 model) so that
# carried/shelf parts look like the actual component instead of a coloured box.
# The source model is instanced once, hidden, and kept off-screen as a template;
# each request duplicates the matching group, applies the model's real-world
# scale/orientation, and recenters it on the part's origin.

const MODEL_PATH := "res://assets/models/bmw_3-series_e36_street/scene.gltf"

# Gameplay part_id -> model group whose subtree is that part's real geometry.
const PART_TO_GROUP := {
	"engine_block": "E36_coupe_engine_m51",
	"gearbox": "E36_coupe_transmission",
	"front_subframe": "E36_subframe_F",
}

var _source: Node = null

func has_visual(part_id: String) -> bool:
	return PART_TO_GROUP.has(part_id)

func make_visual(part_id: String) -> Node3D:
	if not PART_TO_GROUP.has(part_id):
		return null
	_ensure_source()
	if _source == null:
		return null
	var key: String = _norm(String(PART_TO_GROUP[part_id]))
	var grp := _find_group(_source, key)
	if grp == null:
		return null
	var dup := grp.duplicate() as Node3D
	if dup == null:
		return null
	# Bake the model's cumulative transform (cm->m scale + Y-up rotation) so the
	# duplicated geometry ends up at real-world meter scale and upright.
	dup.transform = grp.global_transform
	# Recenter on the part's visual centre.
	var aabbs: Array[AABB] = []
	_collect_mesh_aabbs(dup, Transform3D.IDENTITY, aabbs)
	var holder := Node3D.new()
	holder.name = "PartVisual"
	if aabbs.size() > 0:
		var merged := aabbs[0]
		for i in range(1, aabbs.size()):
			merged = merged.merge(aabbs[i])
		var centre := merged.position + merged.size * 0.5
		dup.position -= centre
	holder.add_child(dup)
	return holder

func _ensure_source() -> void:
	if _source != null:
		return
	var ps: PackedScene = load(MODEL_PATH)
	if ps == null:
		return
	_source = ps.instantiate()
	if _source is Node3D:
		(_source as Node3D).visible = false
	add_child(_source)

static func _norm(s: String) -> String:
	var out := ""
	var low := s.to_lower()
	for i in low.length():
		var ch := low.substr(i, 1)
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			out += ch
	return out

func _find_group(node: Node, key: String) -> Node3D:
	if node is Node3D and _norm(String(node.name)).begins_with(key):
		return node as Node3D
	for c in node.get_children():
		var r := _find_group(c, key)
		if r != null:
			return r
	return null

func _collect_mesh_aabbs(node: Node, xform: Transform3D, out: Array[AABB]) -> void:
	var t := xform
	if node is Node3D:
		t = xform * (node as Node3D).transform
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		out.append(t * (node as MeshInstance3D).mesh.get_aabb())
	for c in node.get_children():
		_collect_mesh_aabbs(c, t, out)
