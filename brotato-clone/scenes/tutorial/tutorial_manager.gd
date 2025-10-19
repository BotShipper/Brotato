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
var is_started := false


# Định nghĩa các bước tutorial
func _ready():
	var save_path = ProjectSettings.globalize_path("user://")
	print("📁 Thư mục save: ", save_path)
	print("📄 File tutorial: ", save_path + "tutorial_completed.save")
	
	hide_tutorial()
	
	


func _process(delta: float) -> void:
	if not is_started:
		return


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
			"arrow_target": null,
			"pause_game": false
		},
		{
			"id": "auto_attack",
			"message": "Tốt lắm! Vũ khí của bạn sẽ tự động tấn công kẻ địch gần nhất.",
			"condition": "wait",
			"wait_time": 5.0,
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
		get_tree().paused = true
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
	get_tree().paused = false
	
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
	Hiển thị mũi tên chỉ vào một đối tượng cụ thể trên màn hình.
	target_name: Tên group của node cần chỉ (vd: "health_bar", "exp_gem", "shop_button")
	
	VÍ DỤ SỬ DỤNG:
	- Nếu bạn muốn chỉ vào thanh máu, thêm vào Health Bar node:
	  add_to_group("health_bar")
	- Nếu muốn chỉ vào viên exp đầu tiên:
	  add_to_group("exp_gem")
	"""
	# Tìm node target trong scene
	var target = get_tree().get_first_node_in_group(target_name)
	if target:
		arrow.visible = true
		
		# Nếu target là Control node (UI), dùng global_position
		if target is Control:
			arrow.global_position = target.global_position + Vector2(0, -60)
		# Nếu target là Node2D (game object)
		elif target is Node2D:
			# Chuyển từ world position sang screen position
			var camera = get_viewport().get_camera_2d()
			if camera:
				var screen_pos = camera.get_screen_center_position()
				var offset = target.global_position - screen_pos
				arrow.position = get_viewport().get_visible_rect().size / 2 + offset + Vector2(0, -60)
			else:
				# Nếu không có camera, dùng global_position trực tiếp
				arrow.global_position = target.global_position + Vector2(0, -60)
		
		# Animation bounce cho arrow
		var tween = create_tween().set_loops()
		tween.tween_property(arrow, "position:y", arrow.position.y - 15, 0.5)
		tween.tween_property(arrow, "position:y", arrow.position.y, 0.5)
	else:
		arrow.visible = false
		print("⚠️ Không tìm thấy target: ", target_name)

# Save/Load tutorial completion
func has_completed_tutorial() -> bool:
	return FileAccess.file_exists("user://tutorial_completed.save")

func save_tutorial_completion():
	var file = FileAccess.open("user://tutorial_completed.save", FileAccess.WRITE)
	file.store_string("completed")
	file.close()

func skip_tutorial():
	"""Cho phép người chơi bỏ qua tutorial"""
	is_tutorial_active = false
	hide_tutorial()
	get_tree().paused = false
	save_tutorial_completion()
	tutorial_finished.emit()
