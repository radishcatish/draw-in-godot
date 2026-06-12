@tool
extends EditorPlugin
var scene_root = EditorInterface.get_edited_scene_root()
var is_drawing: bool = false
var current_line: Line2D
var undo_redo: EditorUndoRedoManager
var active_canvas: Node = null

func _enter_tree() -> void:
	undo_redo = get_undo_redo()
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)

func _exit_tree() -> void:
	if EditorInterface.get_selection().selection_changed.is_connected(_on_selection_changed):
		EditorInterface.get_selection().selection_changed.disconnect(_on_selection_changed)
	active_canvas = null

func _on_selection_changed() -> void:
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	if selected_nodes.size() > 0 and selected_nodes[0] is DrawCanvas:
		active_canvas = selected_nodes[0]
	else:
		active_canvas = null

func _handles(object: Object) -> bool:
	if object is DrawCanvas:
		return true
	else:
		return false

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not active_canvas or not is_instance_valid(active_canvas):
		return false

	if not event.alt_pressed:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_drawing:
			start_line()
			return true
		else:
			stop_line()
			return true
			
	elif is_drawing:
		add_point_to_line()
		return true

	return false
	
var current_poly: Polygon2D = null

func start_line() -> void:
	scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root or not active_canvas:
		return
	is_drawing = true

	var stroke_group = Node2D.new()
	var child_count = str(active_canvas.get_child_count())
	stroke_group.name = "DrawnShape" + child_count
	
	undo_redo.create_action("Draw Closed Shape")
	undo_redo.add_do_method(active_canvas, "add_child", stroke_group)
	undo_redo.add_do_property(stroke_group, "owner", scene_root)
	
	if active_canvas.get("has_polygon"):
		current_poly = Polygon2D.new()
		current_poly.color = active_canvas.get("polygon_color")
		stroke_group.add_child(current_poly)
		undo_redo.add_do_property(current_poly, "owner", scene_root)
		current_poly.name = "Polygon"
	

	current_line = Line2D.new()
	current_line.default_color = active_canvas.get("line_color")
	current_line.width = active_canvas.get("line_width")
	current_line.joint_mode = active_canvas.get("joint_mode")
	current_line.begin_cap_mode = active_canvas.get("begin_cap_mode")
	current_line.end_cap_mode = active_canvas.get("end_cap_mode")
	current_line.name = "Line"

		
	stroke_group.add_child(current_line)
	undo_redo.add_do_property(current_line, "owner", scene_root)
	undo_redo.add_undo_method(active_canvas, "remove_child", stroke_group)
	undo_redo.commit_action()
	var mouse_pos = scene_root.get_global_mouse_position()
	current_line.add_point(mouse_pos)
	

func add_point_to_line() -> void:
	var mouse_pos = scene_root.get_global_mouse_position()
	if current_line.points[-1].distance_to(mouse_pos) > 2.0:
		current_line.add_point(mouse_pos)

		if current_poly:
			current_poly.polygon = current_line.points

func stop_line() -> void:
	is_drawing = false
	current_line = null
	current_poly = null
