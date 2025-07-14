extends Node2D
class_name Arena

@export var player: Player


func _ready() -> void:
	Global.player = player
