extends Node

signal on_create_block_text(unit: Node2D)
signal on_create_damage_text(unit: Node2D, hitbox: HitboxComponent)
signal on_create_heal_text(unit: Node2D, heal: float)

signal on_upgrade_selected
signal on_enemy_died(enemy: Enemy)
signal game_paused_changed(is_paused: bool)

const FLASH_MATERIAL = preload("uid://coi4nu8ohpgeo")
const FLOATING_TEXT_SCENE = preload("uid://bmy2qb3fuvnts")
const COINS_SCENE = preload("uid://c0gxgyeg3phog")
const ITEM_CARD_SCENE = preload("uid://d4ahqxku4821t")
const SELECTION_CARD_SCENE = preload("uid://dnablojs1s8")
const SPAWN_EFFECT_SCENE = preload("uid://bghlbhbjte68a")

const COMMON_STYLE = preload("uid://dn43vff5bgab1")
const EPIC_STYLE = preload("uid://chxsktowv55wp")
const LEGENDARY_STYLE = preload("uid://omjdrwevlaw8")
const RARE_STYLE = preload("uid://cu7iu2w861ga4")

const MAIN_MENU_PATH = "res://scenes/menu/main_menu.tscn"
const ARENA_SCENE_PATH = "res://scenes/arena/arena.tscn"

const TUTORIAL_GROUP = "tutorial_manager"
const JOYSTICK_TAG = "joystick"
const DASH_TAG = "dash"
const COINS_TAG = "coins"
const TIMER_TAG = "timer"
const UPGRADE_TAG = "upgrade"
const SHOP_TAG = "shop"
const COMPLETE_TAG = "complete"


const UPGRADE_PROBABILITY_CONFIG = {
	"rare": { "start_wave": 1, "base_multi": 0.3 },
	"epic": { "start_wave": 2, "base_multi": 0.2 },
	"legendary": { "start_wave": 3, "base_multi": 0.1 },
}

const SHOP_PROBABILITY_CONFIG = {
	"rare": { "start_wave": 1, "base_multi": 0.3 },
	"epic": { "start_wave": 2, "base_multi": 0.2 },
	"legendary": { "start_wave": 3, "base_multi": 0.1 },
}


const TIER_COLORS: Dictionary[UpgradeTier, Color] = {
	UpgradeTier.RARE: Color(0.0, 0.557, 0.741),
	UpgradeTier.EPIC: Color(0.478, 0.251, 0.71),
	UpgradeTier.LEGENDARY: Color(0.906, 0.212, 0.212),
}

var available_players: Dictionary[String, PackedScene] = {
	"Brawler": preload("uid://b6emn4n6ogmg8"),
	"Bunny": preload("uid://dx5yb8804ik6x"),
	"Crazy": preload("uid://dkjqu0ys4k662"),
	"Knight": preload("uid://cecw4o0onlxq8"),
	"Well Rounded": preload("uid://bwo04frw2wqoy"),
}

enum UpgradeTier{
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var coins: int = 500
var player: Player
var game_paused := false:
	set(value):
		game_paused = value
		game_paused_changed.emit(value)
		
var main_player_selected: UnitStats
var main_weapon_selected: ItemWeapon

var equipped_weapons: Array[ItemWeapon]

func get_harvesting_coins() -> void:
	coins += player.stats.harvesting


func get_selected_player() -> Player:
	var player_scene := available_players[main_player_selected.name]
	var player_instance := player_scene.instantiate()
	player = player_instance
	return player


func get_chance_sucess(chance: float) -> bool:
	var random := randf_range(0, 1.0)
	if random < chance:
		return true
	return false

func get_tier_style(tier: UpgradeTier) -> StyleBoxFlat:
	match tier:
		UpgradeTier.COMMON:
			return COMMON_STYLE
		UpgradeTier.RARE:
			return RARE_STYLE
		UpgradeTier.EPIC:
			return EPIC_STYLE
		_:
			return LEGENDARY_STYLE

func calculate_tier_probability(current_wave: int, config: Dictionary) -> Array[float]:
	var common_chance := 0.0
	var rare_chance := 0.0
	var epic_chance := 0.0
	var legendary_chance := 0.0
	
	# RARE: Starts increasing from wave 2 (0% at wave 1)
	if current_wave >= config.rare.start_wave:
		rare_chance = min(1.0, (current_wave) * config.rare.base_multi)
	
	# EPIC: Starts increasing from wave 4 (0% at wave 3)
	if current_wave >= config.epic.start_wave:
		epic_chance = min(1.0, (current_wave - 1) * config.epic.base_multi)
	
	# LEGENDARY: Starts increasing from wave 7 (0% at wave 6)
	if current_wave >= config.legendary.start_wave:
		legendary_chance = min(1.0, (current_wave - 2) * config.legendary.base_multi)
	
	# Player luck increases the chance of finding higher tiers.
	# Example: 10 luck = 10% chance = 1.1 multi
	var luck_factor := 1.0 + (Global.player.stats.luck / 100.0)
	rare_chance *= luck_factor
	epic_chance *= luck_factor
	legendary_chance *= luck_factor
	
	# Normalize probabilities
	var total_non_common_chances := rare_chance + epic_chance + legendary_chance
	if total_non_common_chances > 1.0:
		var scale_down := 1.0 / total_non_common_chances
		rare_chance *= scale_down
		epic_chance *= scale_down
		legendary_chance *= scale_down
		total_non_common_chances = 1.0
	
	# Common takes the remaining probability
	common_chance = 1.0 - total_non_common_chances
	
	# Debug print
	print("Wave: %d, Luck: %.1f => Chances: C:%.2f R:%.2f E:%.2f L:%.2f" % 
	[current_wave, Global.player.stats.luck, common_chance, rare_chance, epic_chance, legendary_chance])
	
	return [
		max(0.0, common_chance),
		max(0.0, rare_chance),
		max(0.0, epic_chance),
		max(0.0, legendary_chance),
	]


func select_items_for_offer(item_pool: Array, current_wave: int, config: Dictionary) -> Array:
	
	# [ 0.7 , 0.2 , 0.08 , 0.02 ]  
	var tier_chances := calculate_tier_probability(current_wave, config)
	
	var legendary_limit = tier_chances[3]
	var epic_limit = legendary_limit + tier_chances[2]
	var rare_limit = epic_limit + tier_chances[1]
	
	var offered_items: Array = []
	while offered_items.size() < 4:
		var roll := randf()
		var chosen_tier_index := 0
		if roll < legendary_limit:
			chosen_tier_index = 3 # Legendary
		elif roll < epic_limit:
			chosen_tier_index = 2 # Epic
		elif roll < rare_limit:
			chosen_tier_index = 1 # Rare
		
		var potential_items: Array = []
		var current_search_tier_index := chosen_tier_index
		
		while potential_items.is_empty() and current_search_tier_index >= 0:
			potential_items = item_pool.filter(func(item: ItemBase): return item.item_tier == current_search_tier_index)
			
			if potential_items.is_empty():
				current_search_tier_index -= 1
			else:
				break
		
		if not potential_items.is_empty():
			var selected_item = potential_items.pick_random()
			
			if not offered_items.has(selected_item):
				offered_items.append(selected_item)
	
	return offered_items
