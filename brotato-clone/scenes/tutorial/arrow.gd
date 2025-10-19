extends Sprite2D
# Script cho Arrow (mũi tên chỉ dẫn)

func _ready():
	# Nếu chưa có texture, tạo một arrow đơn giản bằng Polygon2D
	if texture == null:
		create_simple_arrow()
	
	visible = false
	modulate = Color.YELLOW  # Màu vàng nổi bật

func create_simple_arrow():
	"""Tạo arrow đơn giản nếu chưa có texture"""
	# Tạo một Polygon2D làm con
	var polygon = Polygon2D.new()
	add_child(polygon)
	
	# Hình mũi tên chỉ xuống
	polygon.polygon = PackedVector2Array([
		Vector2(-20, 0),   # Trái
		Vector2(0, -30),   # Trên
		Vector2(20, 0),    # Phải
		Vector2(0, 20)     # Dưới (đầu nhọn)
	])
	
	polygon.color = Color.YELLOW

func point_at(target_position: Vector2):
	"""Quay mũi tên về hướng target"""
	var direction = target_position - global_position
	rotation = direction.angle() + PI/2  # +90 độ vì mũi tên vẽ hướng xuống

func start_bounce_animation():
	"""Animation bounce lên xuống"""
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var start_y = position.y
	tween.tween_property(self, "position:y", start_y - 15, 0.5)
	tween.tween_property(self, "position:y", start_y, 0.5)

func stop_bounce_animation():
	"""Dừng animation"""
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
