@tool
@icon("res://addons/glaze/custom/percent_bar.png")
## A simple UI control to show percent.
class_name PercentBar extends Control

@export var percent:= 0.5
@export var bar_padding:= 2.0
@export var bar_color:= Color.WHITE
@export var back_color:= Color.BLACK
@export var text: String
@export var text_color:= Color.PURPLE

@export var bar: ColorRect
@export var back: ColorRect

func _process(delta: float) -> void:
	back.color = back_color
	back.size = size
	bar.color = bar_color
	bar.size = Vector2((size.x - bar_padding * 2) * clampf(percent, 0, 1), size.y - bar_padding * 2)
