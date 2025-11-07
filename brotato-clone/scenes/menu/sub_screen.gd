extends Panel
class_name SubScreen

@export var fade_speed: float = 1.0
@export var text_fade_speed: float = 0.8

var is_showing: bool = false

@onready var status_label = $StatusLabel
@onready var menu_button = $MenuButton

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Ẩn tất cả ban đầu
	modulate.a = 0
	if status_label:
		status_label.modulate.a = 0
	if menu_button:
		menu_button.modulate.a = 0
	
	visible = false
	is_showing = false

func show_win_screen(win : bool):
	# Tránh gọi nhiều lần
	if is_showing:
		return
	
	if win:
		status_label.text = "You win"
		status_label.label_settings.font_color = Color(1.0, 1.0, 0.0)
	else :
		status_label.text = "You lose"
		status_label.label_settings.font_color = Color(1.0, 0.0, 0.0)
	
	is_showing = true
	print("Showing win screen...")
	
	visible = true
	
	var bg_tween = create_tween()
	bg_tween.tween_property(self, "modulate:a", 0.7, 1.0 / fade_speed)
	
	if status_label:
		var text_tween = create_tween()
		text_tween.tween_property(status_label, "modulate:a", 1.0, 1.5 / text_fade_speed).set_delay(0.5)
	
	if menu_button:
		var button_tween = create_tween()
		button_tween.tween_property(menu_button, "modulate:a", 1.0, 0.8).set_delay(1.5)

# Xử lý khi nhấn nút Menu
func _on_menu_button_pressed():
	print("Menu button pressed")
	get_tree().change_scene_to_file(Global.MAIN_MENU_PATH)
