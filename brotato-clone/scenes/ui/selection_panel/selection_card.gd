#extends Button
#class_name SelectionCard
#
#func set_icon(texture: Texture2D) -> void:
	#icon = texture
#
#
#func _on_pressed() -> void:
	#SoundManager.play_sound(SoundManager.Sound.UI)
#
#
#func _on_mouse_entered() -> void:
	#SoundManager.play_sound(SoundManager.Sound.UI)


extends Button
class_name SelectionCard

# Thông tin để xác định item
var item_type: String = ""  # "characters" hoặc "weapons"
var item_id: String = ""    # "character_1", "weapon_2", etc.
var item_data = null        # UnitStats hoặc ItemWeapon

# UI Elements cho lock overlay
var lock_overlay: Panel
var lock_label: Label
var lock_icon: ColorRect  # Dùng ColorRect thay TextureRect nếu không có icon

func _ready() -> void:
	create_lock_overlay()
	update_lock_state()

func set_icon(texture: Texture2D) -> void:
	icon = texture

# Tạo lock overlay
func create_lock_overlay() -> void:
	# Panel overlay
	lock_overlay = Panel.new()
	lock_overlay.name = "LockOverlay"
	lock_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Style cho panel (nền tối mờ)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.8)
	lock_overlay.add_theme_stylebox_override("panel", style_box)
	add_child(lock_overlay)
	
	# Container để center mọi thứ
	var center_container = VBoxContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.alignment = BoxContainer.ALIGNMENT_CENTER
	lock_overlay.add_child(center_container)
	
	# Icon khóa (Label với emoji lớn)
	var lock_icon_label = Label.new()
	lock_icon_label.text = "🔒"
	lock_icon_label.add_theme_font_size_override("font_size", 40)
	lock_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(lock_icon_label)
	
	# Spacer nhỏ
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	center_container.add_child(spacer)
	
	# Label yêu cầu
	lock_label = Label.new()
	lock_label.name = "RequiredLabel"
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 14)
	lock_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Màu vàng gold
	lock_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	lock_label.add_theme_constant_override("outline_size", 3)
	center_container.add_child(lock_label)

func update_lock_state() -> void:
	if item_type.is_empty() or item_id.is_empty():
		return
	
	var is_unlocked = UnlockManager.is_unlocked(GameManager.total_lifetime_kills,item_type, item_id)
	
	if is_unlocked:
		# Đã unlock
		disabled = false
		modulate = Color.WHITE
		if lock_overlay:
			lock_overlay.visible = false
	else:
		# Còn khóa
		disabled = true
		modulate = Color(0.5, 0.5, 0.5, 0.8)
		
		if lock_overlay:
			lock_overlay.visible = true
			
			var required = UnlockManager.get_required_kills(item_type, item_id)
			
			if lock_label:
				lock_label.text = "🔒 %d kills" % required
		
		# Tooltip
		var required = UnlockManager.get_required_kills(item_type, item_id)
		var current = GameManager.total_lifetime_kills
		var remaining = max(0, required - current)
		
		if remaining > 0:
			tooltip_text = "Cần %d kills để mở khóa\nHiện có: %d kills\nCòn thiếu: %d" % [required, current, remaining]
		else:
			tooltip_text = "Cần %d kills để mở khóa" % required

func _on_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)

func _on_mouse_entered() -> void:
	if not disabled:  # Chỉ phát âm thanh nếu không bị khóa
		SoundManager.play_sound(SoundManager.Sound.UI)
