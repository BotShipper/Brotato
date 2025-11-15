extends Button
class_name DashButton

@export var action_dash := "dash"

var _is_touch_pressed := false
var _touch_index := -1
var has_dash := false

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	add_to_group(Global.DASH_TAG)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		if _is_point_inside_button(touch_pos):
			if event.pressed and _touch_index == -1:
				_touch_index = event.index
				_press_action()
				get_viewport().set_input_as_handled()
				
				# Kiểm tra chuyển động lần đầu tiên
				if not has_dash:
					has_dash = true
					var tutorial = get_tree().get_first_node_in_group(Global.TUTORIAL_GROUP)
					if tutorial:
						tutorial.check_step_condition("dash")
				
			elif not event.pressed and event.index == _touch_index:
				_touch_index = -1
				_release_action()
				get_viewport().set_input_as_handled()


func _release_action() -> void:
	if Input.is_action_pressed(action_dash):
		Input.action_release(action_dash)


func _press_action() -> void:
	if not Input.is_action_pressed(action_dash):
		Input.action_press(action_dash)


func _is_point_inside_button(point: Vector2) -> bool:
	var rect = get_global_rect()
	return rect.has_point(point)


func _on_button_down() -> void:
	if _touch_index == -1:
		_press_action()


func _on_button_up() -> void:
	if _touch_index == -1:
		_press_action()
