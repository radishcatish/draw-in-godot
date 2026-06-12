@tool
extends Node
class_name DrawCanvas

@export_category("Line Configuration")
@export var line_color: Color = Color.WHITE
@export var line_width: float = 5.0

@export_category("Fill Configuration")
@export var has_polygon: bool = false
@export var polygon_color: Color = Color(1, 1, 1, 0.3)

@export_category("Cap & Joints")
@export var joint_mode: Line2D.LineJointMode = Line2D.LINE_JOINT_ROUND
@export var begin_cap_mode: Line2D.LineCapMode = Line2D.LINE_CAP_ROUND
@export var end_cap_mode: Line2D.LineCapMode = Line2D.LINE_CAP_ROUND
