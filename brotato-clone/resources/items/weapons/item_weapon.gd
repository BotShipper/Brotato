extends ItemBase
class_name ItemWeapon

enum WeaponType {
	MELEE,
	RANGE
}

@export var type: WeaponType
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon
