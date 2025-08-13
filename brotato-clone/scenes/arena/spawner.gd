extends Node2D
class_name Spawner

@export var spawn_area_size := Vector2(1000, 500)
@export var waves_data : Array[WaveData]
@export var enemy_collection: Array[UnitStats]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

var wave_index := 5
var current_wave_data: WaveData
var spawned_enemies: Array[Enemy] = []


func find_wave_data() -> WaveData:
	for wave in waves_data:
		if wave and wave.is_valid_index(wave_index):
			return wave
	return null
