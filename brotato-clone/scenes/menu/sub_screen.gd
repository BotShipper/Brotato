extends Panel
class_name SubScreen

# Tốc độ fade
@export var fade_speed: float = 1.0
@export var text_fade_speed: float = 0.8

# Biến để tránh gọi nhiều lần
var is_showing: bool = false

# Node references - điều chỉnh theo tên node của bạn
@onready var status_label = $StatusLabel
@onready var menu_button = $MenuButton

func _ready():
	# Set anchor và size để full màn hình
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Ẩn tất cả ban đầu
	modulate.a = 0
	if status_label:
		status_label.modulate.a = 0
	if menu_button:
		menu_button.modulate.a = 0
	
	# Ẩn toàn bộ màn hình
	visible = false
	is_showing = false
	
	# Set màu background (nếu cần)
	# Có thể set trong Inspector hoặc dùng StyleBox

# Gọi hàm này khi người chơi thắng
func show_win_screen():
	# Tránh gọi nhiều lần
	if is_showing:
		return
	
	is_showing = true
	print("Showing win screen...")
	
	# Hiển thị màn hình
	visible = true
	
	# Tween cho panel background
	var bg_tween = create_tween()
	bg_tween.tween_property(self, "modulate:a", 0.7, 1.0 / fade_speed)
	
	# Tween cho chữ "You Win" (bắt đầu sau background)
	if status_label:
		var text_tween = create_tween()
		text_tween.tween_property(status_label, "modulate:a", 1.0, 1.5 / text_fade_speed).set_delay(0.5)
	
	# Tween cho nút menu (xuất hiện sau chữ)
	if menu_button:
		var button_tween = create_tween()
		button_tween.tween_property(menu_button, "modulate:a", 1.0, 0.8).set_delay(1.5)

# Xử lý khi nhấn nút Menu
func _on_menu_button_pressed():
	print("Menu button pressed")
	# Chuyển về màn hình chính - thay đổi đường dẫn cho đúng
	get_tree().change_scene_to_file(Global.MAIN_MENU_PATH)
