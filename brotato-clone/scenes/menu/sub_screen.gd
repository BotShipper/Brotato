extends Panel
class_name SubScreen

@export var fade_speed: float = 1.0
@export var text_fade_speed: float = 0.8

var is_showing: bool = false

@onready var status_label = $StatusLabel
@onready var menu_button = $MenuButton

# THÊM MỚI: Labels cho kills stats
@onready var kills_label: Label = %KillsLabel
@onready var record_label: Label = %RecordLabel
@onready var new_record_label: Label = %NewRecordLabel

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Ẩn tất cả ban đầu
	modulate.a = 0
	if status_label:
		status_label.modulate.a = 0
	if menu_button:
		menu_button.modulate.a = 0
	if kills_label:
		kills_label.modulate.a = 0
	if record_label:
		record_label.modulate.a = 0
	if new_record_label:
		new_record_label.modulate.a = 0
		new_record_label.visible = false
	
	visible = false
	is_showing = false

func show_win_screen(win: bool):
	# Tránh gọi nhiều lần
	if is_showing:
		return
	
	# Lấy stats từ GameManager
	var run_stats = GameManager.end_run()
	
	# Set text Win/Lose
	if win:
		status_label.text = "YOU WIN"
		status_label.label_settings.font_color = Color(1.0, 1.0, 0.0)
	else:
		status_label.text = "YOU LOSE"
		status_label.label_settings.font_color = Color(1.0, 0.0, 0.0)
	
	# Hiển thị kills stats
	_setup_kills_display(run_stats)
	
	is_showing = true
	print("Showing win screen...")
	
	visible = true
	
	# Animation fade in
	var bg_tween = create_tween()
	bg_tween.tween_property(self, "modulate:a", 0.7, 1.0 / fade_speed)
	
	# Fade in status label (WIN/LOSE)
	if status_label:
		var text_tween = create_tween()
		text_tween.tween_property(status_label, "modulate:a", 1.0, 1.5 / text_fade_speed).set_delay(0.5)
	
	# Fade in kills stats
	if kills_label:
		var kills_tween = create_tween()
		kills_tween.tween_property(kills_label, "modulate:a", 1.0, 0.8).set_delay(1.0)
	
	if record_label:
		var record_tween = create_tween()
		record_tween.tween_property(record_label, "modulate:a", 1.0, 0.8).set_delay(1.3)
	
	# Nếu phá kỷ lục, hiển thị thông báo đặc biệt
	if run_stats.is_new_record and new_record_label:
		new_record_label.visible = true
		var new_record_tween = create_tween()
		new_record_tween.tween_property(new_record_label, "modulate:a", 1.0, 0.5).set_delay(1.6)
		# Animation nhấp nháy
		_animate_new_record()
	
	# Fade in menu button
	if menu_button:
		var button_tween = create_tween()
		button_tween.tween_property(menu_button, "modulate:a", 1.0, 0.8).set_delay(2.0)

func _setup_kills_display(run_stats: Dictionary):
	var kills = run_stats.kills
	var is_new_record = run_stats.is_new_record
	var record = run_stats.record
	
	# Hiển thị số kills lượt này
	if kills_label:
		kills_label.text = "Kills: %d" % kills
		if is_new_record:
			kills_label.label_settings.font_color = Color(1.0, 0.84, 0.0)  # Gold
		else:
			kills_label.label_settings.font_color = Color(1.0, 1.0, 1.0)  # White
	
	# Hiển thị record
	if record_label:
		if is_new_record:
			record_label.text = "Previous Record: %d" % (record - kills)
		else:
			record_label.text = "Record: %d" % record
		record_label.label_settings.font_color = Color(0.8, 0.8, 0.8)  # Gray
	
	# Hiển thị thông báo kỷ lục mới
	if new_record_label and is_new_record:
		new_record_label.text = "🏆 NEW RECORD! 🏆"
		new_record_label.label_settings.font_color = Color(1.0, 0.84, 0.0)  # Gold

func _animate_new_record():
	if not new_record_label:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(new_record_label, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(new_record_label, "scale", Vector2(1.0, 1.0), 0.5)

func _on_menu_button_pressed():
	print("Menu button pressed")
	get_tree().change_scene_to_file(Global.MAIN_MENU_PATH)
