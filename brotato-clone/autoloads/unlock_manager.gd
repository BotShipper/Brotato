# unlock_system.gd (AutoLoad/Singleton)
extends Node

const SAVE_PATH = "user://unlock_data.save"

# Định nghĩa điều kiện unlock
var unlock_requirements = {
	"characters": {
		"character_1": 0,      # Mở sẵn
		"character_2": 10,     # Cần 10 kills
		"character_3": 50,     # Cần 50 kills
		"character_4": 150,    # Cần 150 kills
		"character_5": 300     # Cần 300 kills
	},
	"weapons": {
		"weapon_1": 0,         # Mở sẵn
		"weapon_2": 5,
		"weapon_3": 20,
		"weapon_4": 75,
		"weapon_5": 100,
		"weapon_6": 200,
		"weapon_7": 250,
		"weapon_8": 350,
		"weapon_9": 500,
		"weapon_10": 750,
		"weapon_11": 1000
	}
}

func is_unlocked(total_kills: int, type: String, id: String) -> bool:
	if not unlock_requirements.has(type):
		return false
	if not unlock_requirements[type].has(id):
		return false
	
	var required_kills = unlock_requirements[type][id]
	return total_kills >= required_kills

func get_required_kills(type: String, id: String) -> int:
	if unlock_requirements.has(type) and unlock_requirements[type].has(id):
		return unlock_requirements[type][id]
	return 0
