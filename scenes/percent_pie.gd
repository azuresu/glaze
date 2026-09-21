@tool
@icon("res://addons/glaze/custom/percent_pie.png")
## A simple UI control to show percent.
class_name PercentPie extends Control

@export var percent:= 0.5
@export var back_color:= Color.BLACK
@export var pie_color:= Color.WHITE
@export var segments:= 64:
	set(s): segments = maxi(4, s)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, size.x, size.y), back_color)
	var end_angle:= -PI * 0.5 + TAU * clampf(percent, 0, 1)
	draw_arc(Vector2(size.x * 0.5, size.y * 0.5), size.x * 0.5, -PI * 0.5, end_angle, segments, pie_color, size.x)
