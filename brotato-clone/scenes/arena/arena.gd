extends Node2D
class_name Arena

@export var player: Player

@export var normal_color: Color
@export var blocked_color: Color
@export var critical_color: Color
@export var hp_color: Color

func _ready() -> void:
	Global.player = player
	Global.on_create_block_text.connect(_on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)


func create_floating_text(unit: Node2D) -> FloatingText:
	var instance := Global.FLOATING_TEXT_SCENE.instantiate() as FloatingText
	get_tree().root.add_child(instance)
	var random_pos := randf_range(0, TAU) * 35
	var spawn_pos := unit.global_position + Vector2.RIGHT.rotated(random_pos)
	instance.global_position = spawn_pos
	return instance


func _on_create_block_text(unit: Node2D) -> void:
	var text :=  create_floating_text(unit)
	text.setup("Blocked!", blocked_color)


func _on_create_damage_text(unit: Node2D, hitbox: HitboxComponent) -> void:
	var text :=  create_floating_text(unit)
	var color := critical_color if hitbox.critical else normal_color
	text.setup(str(hitbox.damage), color)
