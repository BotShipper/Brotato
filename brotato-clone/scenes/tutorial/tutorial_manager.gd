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
			"message": "Welcome to the game! Use WASD or arrow keys to move.",
			"condition": "move",
			"arrow_target": Global.JOYSTICK_TAG,
			"pause_game": true
		},
		{
			"id": "dash",
			"message": "You can dash to dodge.",
			"condition": "dash",
			"arrow_target": Global.DASH_TAG,
			"pause_game": true
		},
		{
			"id": "auto_attack",
			"message": "Well done! Your weapon will automatically attack the nearest enemy.",
			"condition": "wait",
			"wait_time": 3.0,
			"arrow_target": null,
			"pause_game": false
		},
		{
			"id": "kill_enemy",
			"message": "Defeat enemies to earn coins and collect them",
			"condition": "wait",
			"wait_time": 3.0,
			"arrow_target": null,
			"pause_game": false
		},
		{
			"id": "survive_wave",
			"message": "Survive each wave of monsters! Remaining time is displayed at the top.",
			"condition": "wave_complete",
			"arrow_target": Global.TIMER_TAG,
			"pause_game": false
		},
		{
			"id": "upgrade",
			"message": "Between waves, you can choose upgrades for your character!",
			"condition": "upgrade_open",
			"arrow_target": Global.UPGRADE_TAG,
			"pause_game": false
		},
		{
			"id": "shop",
			"message": "You can buy weapons and upgrades at the shop!",
			"condition": "shop_open",
			"arrow_target": Global.SHOP_TAG,
			"pause_game": false
		},
		{
			"id": "complete",
			"message": "Excellent! You're now ready to fight! Good luck!",
			"condition": "complete",
			"arrow_target": Global.COMPLETE_TAG,
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
	progress_label.text = "Step %d/%d" % [current_step_index + 1, tutorial_steps.size()]
	
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
	Tự động chọn vị trí tốt nhất (trên/dưới/trái/phải) để luôn hiển thị trong viewport.
	
	Ví dụ sử dụng:
	  add_to_group("health_bar") trong node cần chỉ
	  show_arrow_to_target("health_bar")
	"""
	# Đợi nhiều frame để đảm bảo layout đã được cập nhật hoàn toàn
	# Đặc biệt quan trọng khi target nằm trong panel vừa mới hiển thị
	for i in range(3):
		await get_tree().process_frame
	
	# Tìm node target trong scene
	var target = get_tree().get_first_node_in_group(target_name)
	
	if target:
		var target_position: Vector2
		var target_rect: Rect2
		
		# Xử lý khác nhau cho Control node (UI) và Node2D (game object)
		if target is Control:
			target_rect = target.get_global_rect()
			# Lấy điểm giữa của rect
			target_position = target_rect.get_center()
		elif target is Node2D:
			target_position = target.global_position
			# Tạo rect giả cho Node2D (kích thước 50x50 cho đơn giản)
			target_rect = Rect2(target_position - Vector2(25, 25), Vector2(50, 50))
		else:
			target_position = target.global_position if "global_position" in target else Vector2.ZERO
			target_rect = Rect2(target_position - Vector2(25, 25), Vector2(50, 50))
		
		# Lấy kích thước viewport
		var viewport_size = get_viewport().get_visible_rect().size
		
		# Khoảng cách an toàn từ mép màn hình
		var safe_margin = 200
		var arrow_offset = 50  # Khoảng cách từ target đến arrow
		
		# Tính khoảng trống ở 4 hướng
		var space_top = target_position.y
		var space_bottom = viewport_size.y - target_position.y
		var space_left = target_position.x
		var space_right = viewport_size.x - target_position.x
		
		# Chọn vị trí tốt nhất dựa trên khoảng trống
		var arrow_pos: Vector2
		var rotation: float
		var animation_axis: String
		
		# Ưu tiên: Dưới > Trên > Phải > Trái
		if space_bottom > safe_margin + arrow_offset:
			# Đặt arrow ở dưới, chỉ lên
			arrow_pos = Vector2(target_position.x, target_rect.position.y + target_rect.size.y + arrow_offset)
			rotation = -90
			animation_axis = "y"
		elif space_top > safe_margin + arrow_offset:
			# Đặt arrow ở trên, chỉ xuống
			arrow_pos = Vector2(target_position.x, target_rect.position.y - arrow_offset)
			rotation = 90
			animation_axis = "y"
		elif space_right > safe_margin + arrow_offset:
			# Đặt arrow ở phải, chỉ sang trái
			arrow_pos = Vector2(target_rect.position.x + target_rect.size.x + arrow_offset, target_position.y)
			rotation = 180
			animation_axis = "x"
		elif space_left > safe_margin + arrow_offset:
			# Đặt arrow ở trái, chỉ sang phải
			arrow_pos = Vector2(target_rect.position.x - arrow_offset, target_position.y)
			rotation = 0
			animation_axis = "x"
		else:
			# Không đủ chỗ ở bất kỳ hướng nào, đặt ở giữa màn hình
			arrow_pos = viewport_size / 2
			rotation = 180
			animation_axis = "y"
		
		# Đảm bảo arrow luôn trong viewport
		arrow_pos.x = clamp(arrow_pos.x, safe_margin * 0.5, viewport_size.x - safe_margin * 0.5)
		arrow_pos.y = clamp(arrow_pos.y, safe_margin * 0.5, viewport_size.y - safe_margin * 0.5)
		
		arrow.global_position = arrow_pos
		arrow.rotation_degrees = rotation
		arrow.visible = true
		
		# Debug để kiểm tra
		print("🎯 Arrow pointing to: ", target.name)
		print("   Target position: ", target_position)
		print("   Arrow position: ", arrow.global_position)
		print("   Arrow rotation: ", rotation, "°")
		print("   Spaces - Top: %.0f, Bottom: %.0f, Left: %.0f, Right: %.0f" % [space_top, space_bottom, space_left, space_right])
		
		# Animation bounce thông minh theo trục phù hợp
		var tween = create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		
		var bounce_distance = 15
		if animation_axis == "y":
			var base_y = arrow.position.y
			tween.tween_property(arrow, "position:y", base_y + (bounce_distance if rotation == 180 else -bounce_distance), 0.5)
			tween.tween_property(arrow, "position:y", base_y, 0.5)
		else:  # animation_axis == "x"
			var base_x = arrow.position.x
			tween.tween_property(arrow, "position:x", base_x + (bounce_distance if rotation == 90 else -bounce_distance), 0.5)
			tween.tween_property(arrow, "position:x", base_x, 0.5)
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
