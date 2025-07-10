extends Resource
class_name UnitStats

enum UnitType {
	PLAYER,
	ENEMY
}

@export var name: String
@export var type: UnitType
@export var icon: Texture2D
@export var health := 1
@export var health_increase_per_wave := 1.0
@export var damage := 1
@export var damage_increase_per_wave := 1.0
@export var speed := 300
@export var luck := 1.0
@export var block_chance := 0.0
@export var gold_drop := 1
