extends ItemBase
class_name ItemUpgrade

@export var value: float
@export var description: String
@export var stats_id: String


func apply_upgrade() -> void:
	var current_value := Global.player.stats.get(stats_id) as float
	var new_value := float(value) + float(current_value)
	Global.player.stats.set(stats_id ,new_value)
