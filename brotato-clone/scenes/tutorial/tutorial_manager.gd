extends CanvasLayer

# Quản lý tutorial từng bước trong game
class_name TutorialManager

# Signals để thông báo khi tutorial hoàn thành
signal tutorial_step_completed(step_id: String)
signal tutorial_finished()

# Node references
@onready var tutorial_panel: Panel = $TutorialPanel
@onready var progress_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/ProgressLabel
@onready var message_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/MessageLabel
@onready var arrow: Sprite2D = $Arrow

# Tutorial steps data
var tutorial_steps = []
var current_step_index = 0
var is_tutorial_active = false
var tutorial_completed = false

var is_started = false

# Định nghĩa các bước tutorial
func _ready():
	var save_path = ProjectSettings.globalize_path("user://")
	print("📁 Thư mục save: ", save_path)
	print("📄 File tutorial: ", save_path + "tutorial_completed.save")
	
	hide_tutorial()


func start() -> void:
	is_started = true
	visible = true
	# Bắt đầu tutorial step đầu tiên
	setup_tutorial_steps()
	
	# Kiểm tra xem người chơi đã hoàn thành tutorial chưa
	if not has_completed_tutorial():
		start_tutorial()

func setup_tutorial_steps():
	tutorial_steps = [
		{
			"id": "welcome",
			"message": "Chào mừng đến với game! Sử dụng WASD hoặc phím mũi tên để di chuyển.",
			"condition": "move",
			"arrow_target": "joystick",
			"pause_game": true
		},
		{
			"id": "auto_attack",
			"message": "Tốt lắm! Vũ khí của bạn sẽ tự động tấn công kẻ địch gần nhất.",
			"condition": "wait",
			"wait_time": 3.0,
			"arrow_target": null,
			"pause_game": false
		},
		{
			"id": "collect_exp",
			"message": "Hạ gục kẻ địch để nhận kinh nghiệm (XP). Đi thu thập chúng!",
			"condition": "collect_exp",
			"arrow_target": "exp_gem",
			"pause_game": false
		},
		{
			"id": "level_up",
			"message": "Khi lên cấp, bạn có thể chọn nâng cấp vũ khí hoặc chỉ số!",
			"condition": "level_up",
			"arrow_target": null,
			"pause_game": true
		},
		{
			"id": "survive_wave",
			"message": "Hãy sống sót qua từng đợt quái! Thời gian còn lại hiển thị ở góc trên.",
			"condition": "wave_complete",
			"arrow_target": "timer",
			"pause_game": false
		},
		{
			"id": "shop",
			"message": "Giữa các đợt, bạn có thể mua vũ khí và nâng cấp tại cửa hàng!",
			"condition": "shop_open",
			"arrow_target": null,
			"pause_game": true
		},
		{
			"id": "complete",
			"message": "Tuyệt vời! Bây giờ bạn đã sẵn sàng chiến đấu! Chúc may mắn!",
			"condition": "wait",
			"wait_time": 3.0,
			"arrow_target": null,
			"pause_game": false
		}
	]

func start_tutorial():
	is_tutorial_active = true
	current_step_index = 0
	show_current_step()

func show_current_step():
	if current_step_index >= tutorial_steps.size():
		finish_tutorial()
		return
	
	var step = tutorial_steps[current_step_index]
	
	# Hiển thị message
	message_label.text = step.message
	progress_label.text = "Bước %d/%d" % [current_step_index + 1, tutorial_steps.size()]
	
	# Show tutorial panel
	tutorial_panel.visible = true
	
	# === XỬ LÝ ARROW TARGET ===
	# Nếu có arrow_target, hiển thị mũi tên chỉ vào đối tượng đó
	if step.has("arrow_target") and step.arrow_target != null:
		show_arrow_to_target(step.arrow_target)
	else:
		arrow.visible = false
	
	# === XỬ LÝ PAUSE GAME ===
	# Pause game khi cần (vd: khi hiển thị màn hình level up hoặc shop)
	if step.get("pause_game", false):
		print("🎮 Tutorial đang tạm dừng game")
		Global.game_paused = true
		# Đảm bảo UI tutorial vẫn hoạt động khi pause
		process_mode = Node.PROCESS_MODE_ALWAYS
	
	# === XỬ LÝ ĐIỀU KIỆN WAIT ===
	# Nếu điều kiện là "wait", tự động chuyển sang bước tiếp theo sau một khoảng thời gian
	if step.condition == "wait":
		print("⏳ Đợi %.1f giây..." % step.get("wait_time", 2.0))
		await get_tree().create_timer(step.get("wait_time", 2.0)).timeout
		complete_current_step()

func complete_current_step():
	if not is_tutorial_active:
		return
	
	var step = tutorial_steps[current_step_index]
	
	# Emit signal
	tutorial_step_completed.emit(step.id)
	
	# Unpause game
	Global.game_paused = false
	
	# Chuyển sang bước tiếp theo
	current_step_index += 1
	
	if current_step_index < tutorial_steps.size():
		await get_tree().create_timer(0.5).timeout
		show_current_step()
	else:
		finish_tutorial()

func check_step_condition(condition_type: String):
	"""Gọi hàm này từ game code khi có sự kiện xảy ra"""
	if not is_tutorial_active:
		return
	
	var step = tutorial_steps[current_step_index]
	
	if step.condition == condition_type:
		complete_current_step()

func finish_tutorial():
	is_tutorial_active = false
	tutorial_completed = true
	hide_tutorial()
	
	# Lưu trạng thái đã hoàn thành tutorial
	save_tutorial_completion()
	
	tutorial_finished.emit()

func hide_tutorial():
	tutorial_panel.visible = false
	arrow.visible = false

func show_arrow_to_target(target_name: String):
	"""
	Hiển thị mũi tên chỉ vào một đối tượng cụ thể.
	
	Ví dụ sử dụng:
	  add_to_group("health_bar") trong node cần chỉ
	  show_arrow_to_target("health_bar")
	"""
	# Tìm node target trong scene
	var target = get_tree().get_first_node_in_group(target_name)
	
	if target:
		var target_position: Vector2
		
		# Xử lý khác nhau cho Control node (UI) và Node2D (game object)
		if target is Control:
			# Với Control node: lấy vị trí THỰC TẾ trên màn hình
			# get_global_rect() trả về Rect2 với position và size THỰC TẾ sau khi tính anchor, margin
			var rect = target.get_global_rect()
			# Lấy điểm giữa trên cùng của rect
			target_position = Vector2(rect.position.x + rect.size.x / 2, rect.position.y)
			
		elif target is Node2D:
			# Với Node2D: dùng global_position như bình thường
			target_position = target.global_position
		else:
			# Fallback cho các loại node khác
			target_position = target.global_position if "global_position" in target else Vector2.ZERO
		
		# Đặt arrow ở trên target
		arrow.global_position = target_position + Vector2(0, -80)
		arrow.visible = true
		
		# Debug để kiểm tra
		print("🎯 Arrow pointing to: ", target.name)
		print("   Target rect: ", target.get_global_rect() if target is Control else "N/A")
		print("   Arrow position: ", arrow.global_position)
		
		# Animation bounce đơn giản
		var tween = create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(arrow, "position:y", arrow.position.y - 15, 0.5)
		tween.tween_property(arrow, "position:y", arrow.position.y, 0.5)
	else:
		arrow.visible = false
		print("⚠️ Không tìm thấy target: ", target_name)

# Save/Load tutorial completion
const SAVE_PATH = "user://tutorial_completed.save"

func has_completed_tutorial() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_tutorial_completion():
	var save_data = {
		"completed": true,
		"completed_at": Time.get_datetime_string_from_system(),
		"version": "1.0"
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))  # Thêm indent cho dễ đọc
		file.close()
		print("💾 Tutorial completion saved to: ", ProjectSettings.globalize_path(SAVE_PATH))
	else:
		print("❌ Failed to save tutorial completion")

func reset_tutorial():
	"""Xóa file save để chơi lại tutorial"""
	if FileAccess.file_exists(SAVE_PATH):
		var global_path = ProjectSettings.globalize_path(SAVE_PATH)
		DirAccess.remove_absolute(global_path)
		print("🗑️ Tutorial save deleted")
		
		# Restart tutorial
		is_tutorial_active = false
		tutorial_completed = false
		current_step_index = 0
		start_tutorial()
	else:
		print("⚠️ No tutorial save file found")

func open_save_folder():
	"""Mở thư mục chứa file save"""
	var path = ProjectSettings.globalize_path("user://")
	OS.shell_open(path)
	print("📁 Opened save folder: ", path)

func skip_tutorial():
	"""Cho phép người chơi bỏ qua tutorial"""
	is_tutorial_active = false
	hide_tutorial()
	Global.game_paused = false
	save_tutorial_completion()
	tutorial_finished.emit()
