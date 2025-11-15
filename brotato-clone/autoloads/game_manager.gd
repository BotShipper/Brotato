extends Node

# Stats lượt chơi hiện tại
var current_run_kills: int = 0

# Kỷ lục cao nhất
var record_kills: int = 0

# Stats tổng hợp
var total_runs_played: int = 0
var total_lifetime_kills: int = 0

signal enemy_killed(total_kills: int)
signal run_ended(kills: int, is_new_record: bool)

const SAVE_PATH = "user://game_stats.save"

func _ready():
	load_stats()

# Khi bắt đầu lượt chơi mới
func start_new_run():
	current_run_kills = 0
	total_runs_played += 1
	print("=== BẮT ĐẦU LƯỢT CHƠI MỚI ===" )
	if record_kills > 0:
		print("Kỷ lục cần phá: %d kills" % record_kills)

# Khi giết 1 enemy
func register_enemy_killed():
	current_run_kills += 1
	total_lifetime_kills += 1
	emit_signal("enemy_killed", current_run_kills)

# Khi kết thúc lượt chơi
func end_run() -> Dictionary:
	var is_new_record = current_run_kills > record_kills
	
	if is_new_record:
		print("🏆 KỶ LỤC MỚI! %d kills (cũ: %d)" % [current_run_kills, record_kills])
		record_kills = current_run_kills
	else:
		print("Lượt chơi kết thúc: %d kills (Kỷ lục: %d)" % [current_run_kills, record_kills])
	
	emit_signal("run_ended", current_run_kills, is_new_record)
	save_stats()
	
	return {
		"kills": current_run_kills,
		"is_new_record": is_new_record,
		"record": record_kills
	}

# Lưu/Load dữ liệu
func save_stats():
	var save_data = {
		"record_kills": record_kills,
		"total_runs_played": total_runs_played,
		"total_lifetime_kills": total_lifetime_kills
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_stats():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			record_kills = data.get("record_kills", 0)
			total_runs_played = data.get("total_runs_played", 0)
			total_lifetime_kills = data.get("total_lifetime_kills", 0)
			print("✅ Đã load - Kỷ lục: %d kills" % record_kills)
