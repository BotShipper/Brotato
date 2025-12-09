extends Control
class_name MainMenu

# THÊM MỚI: Reference đến label hiển thị record
@onready var record_label: Label = %RecordLabel
@onready var stats_label: Label = %StatsLabel
@onready var volume_setting: Control = $VolumeSetting

func _ready():
	_update_record_display()

func _update_record_display():
	# Hiển thị kỷ lục
	if record_label:
		if GameManager.record_kills > 0:
			record_label.text = "🏆 Best: %d Kills" % GameManager.record_kills
			record_label.label_settings.font_color = Color(1.0, 0.84, 0.0)  # Gold
		else:
			record_label.text = "No record yet"
			record_label.label_settings.font_color = Color(0.8, 0.8, 0.8)  # Gray
	
	# Stats tổng hợp (optional)
	if stats_label and GameManager.total_runs_played > 0:
		stats_label.text = "Runs: %d | Total Kills: %d" % [
			GameManager.total_runs_played,
			GameManager.total_lifetime_kills
		]
		stats_label.label_settings.font_color = Color(0.7, 0.7, 0.7)

func _on_start_button_pressed() -> void:
	# THÊM DÒNG NÀY để bắt đầu lượt chơi mới
	GameManager.start_new_run()
	get_tree().change_scene_to_file(Global.ARENA_SCENE_PATH)

func _on_setting_button_pressed() -> void:
	volume_setting.visible = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	volume_setting.visible = false
